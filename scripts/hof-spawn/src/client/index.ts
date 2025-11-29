import Config from '@common/config';

declare global {
  function onNet(eventName: string, callback: (...args: any[]) => void): void;
  function emitNet(eventName: string, ...args: any[]): void;
  function SetNuiFocus(focus: boolean, cursor: boolean): void;
  function SendNUIMessage(data: any): void;
  function RegisterNuiCallback(eventName: string, callback: (data: any, cb: (data: any) => void) => void): void;
  function PlayerPedId(): number;
  function GetPlayerData(): any;
  function CreateCamWithParams(camType: string, x: number, y: number, z: number, rotX: number, rotY: number, rotZ: number, fov: number, p8: boolean, p9: number): number;
  function SetCamActive(cam: number, active: boolean): void;
  function RenderScriptCams(render: boolean, ease: boolean, easeTime: number, p3: boolean, p4: boolean): void;
  function PointCamAtCoord(cam: number, x: number, y: number, z: number): void;
  function SetCamActiveWithInterp(from: number, to: number, duration: number, p3: boolean, p4: boolean): void;
  function DoesCamExist(cam: number): boolean;
  function DestroyCam(cam: number, p1: boolean): void;
  function SetEntityCoords(entity: number, x: number, y: number, z: number): void;
  function DoScreenFadeOut(duration: number): void;
  function DoScreenFadeIn(duration: number): void;
  function FreezeEntityPosition(entity: number, toggle: boolean): void;
  function SetEntityVisible(entity: number, toggle: boolean, p2?: number): void;
  function IsEntityDead(entity: number): boolean;
  function GetClockHours(): number;
  function GetClockMinutes(): number;
  function GetWindSpeed(): number;
  function TriggerEvent(eventName: string, ...args: any[]): void;
  function TriggerServerEvent(eventName: string, ...args: any[]): void;
  function Wait(ms: number): Promise<void>;
  const lib: any;
}


let LastLocation: any = null;
let QBCore: any = null;

//! Initialize QBX/QBCore (Using legacy for compaat)
try {
  QBCore = (globalThis as any).exports?.['qb-core']?.GetCoreObject();
} catch (e) {
  //! Couldn't get QBCore object
  console.warn('[hof-spawn] Could not get QBCore object during initialization');
}

function SendReactMessage(action: string, data: any) {
  SendNUIMessage({
    action: action,
    data: data
  });
}

function ToggleNuiFrame(shouldShow: boolean) {
  SetNuiFocus(shouldShow, shouldShow);
  SendReactMessage('setVisible', shouldShow);
  SetSpawnInterfaceVisibility(shouldShow);
}

function SetupCameraTransition(camPos: {x: number, y: number, z: number}) {
  //? Simple fade to black, teleport, then fade in
  const PlayerPed = PlayerPedId();
  
  //? Prepare player (freeze and invis during transition)
  FreezeEntityPosition(PlayerPed, true);
  SetEntityVisible(PlayerPed, false, 0);
  
  //? Start fade to black
  DoScreenFadeOut(1000);
  
  setTimeout(() => {
    //? Set player position while screen is faded out
    SetEntityCoords(PlayerPed, camPos.x, camPos.y, camPos.z);
    
    //? disable scripted cameras
    RenderScriptCams(false, false, 1, true, true);
    
    //? Wait for property warp to complete, then fade in
    setTimeout(() => {
      FreezeEntityPosition(PlayerPed, false);
      SetEntityVisible(PlayerPed, true, 0);
      
      //? Fade back in
      DoScreenFadeIn(1500);
    }, 200);
  }, 1000);
}

//! Net Event Handlers
onNet('hof-spawn:initInterface', () => {
  if (hasPlayerSpawned) {
    console.log('[hof-spawn] Ignoring init request - player has already spawned');
    return;
  }

  DoScreenFadeOut(250);
  Wait(1000);
  DoScreenFadeIn(250);
  ToggleNuiFrame(true);
  SendReactMessage('setLocations', Config.Locations);


  //? Send initial time and weather data from statebags to React
  const weatherInfo = GetCurrentWeatherInfo();
  const dateString = getFormattedDateClient();
  const Info = {
    time: GetCurrentTime(),
    date: dateString,
    weather: weatherInfo.weather,
    wind: weatherInfo.windSpeed
  };
  SendReactMessage('updateInfo', Info);
  
  if (QBCore) {
    const PlayerData = QBCore.Functions.GetPlayerData();
    if (PlayerData && PlayerData.position) {
      LastLocation = { x: PlayerData.position.x, y: PlayerData.position.y, z: PlayerData.position.z };
    }
  }
  
  const Camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -206.19, -1013.78, 30.13 + 1000, -85.00, 0.00, 0.00, 100.00, false, 0);
  SetCamActive(Camera, true);
  RenderScriptCams(true, false, 1, true, true);
});

function Round(number: number): number {
  return Math.floor(number + 0.5);
}

function getWeatherDisplayName(weatherCode: string): string {
  const weatherMap: { [key: string]: string } = {
    'BLIZZARD': 'Blizzard',
    'CLEAR': 'Clear',
    'CLEARING': 'Clearing',
    'CLOUDS': 'Cloudy',
    'EXTRASUNNY': 'Extra Sunny',
    'FOGGY': 'Foggy',
    'NEUTRAL': 'Neutral',
    'OVERCAST': 'Overcast',
    'RAIN': 'Rainy',
    'SMOG': 'Smoggy',
    'SNOW': 'Snowy',
    'SNOWLIGHT': 'Light Snow',
    'THUNDER': 'Thunderstorm',
    'XMAS': 'Christmas Snow'
  };
  
  return weatherMap[weatherCode] || weatherCode;
}

function GetCurrentTime(): string {
  //? Uses renewed_weather statebags for time data
  const globalState = (globalThis as any).GlobalState;
  if (globalState?.currentTime) {
    const timeData = globalState.currentTime;
    if (typeof timeData.hour !== 'undefined' && typeof timeData.minute !== 'undefined') {
      let hour = timeData.hour;
      const minute = timeData.minute;
      let amPm = "AM";
      
      if (hour >= 12) {
        amPm = "PM";
        if (hour > 12) {
          hour = hour - 12;
        }
      }
      if (hour === 0) {
        hour = 12; //? Use 12 AM for midnight
      }
      
      return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')} ${amPm}`;
    }
  }
  
  //? Just fallback to whatever the natives return incase the statebag is unavailable lul
  let Hour = GetClockHours();
  const Minute = GetClockMinutes();
  let AmPm = "AM";
  if (Hour >= 12) {
    AmPm = "PM";
    if (Hour > 12) {
      Hour = Hour - 12;
    }
  }
  if (Hour === 0) {
    Hour = 12;
  }
  return `${Hour.toString().padStart(2, '0')}:${Minute.toString().padStart(2, '0')} ${AmPm}`;
}

function GetCurrentWeatherInfo(): { weather: string; windSpeed: number } {
  //? Uses renewed_weather statebags for weather data
  const globalState = (globalThis as any).GlobalState;
  if (globalState?.weather) {
    const weatherData = globalState.weather;
    if (weatherData.weather && typeof weatherData.windSpeed !== 'undefined') {
      return {
        weather: getWeatherDisplayName(weatherData.weather),
        windSpeed: weatherData.windSpeed
      };
    }
  }
  
  //? Fallback to preset data if statebag is unavailable
  return {
    weather: 'Clear',
    windSpeed: 10,
  };
}


//! Track interface visibility

let isSpawnInterfaceVisible = false;

function SetSpawnInterfaceVisibility(visible: boolean) {
  //? Player already spawned, return.
  if (hasPlayerSpawned) {
    return;
  }
  
  const wasVisible = isSpawnInterfaceVisible;
  isSpawnInterfaceVisible = visible;
  
  //? If UI just became visible, send immediate update and restart timer
  if (visible && !wasVisible) {
    const weatherInfo = GetCurrentWeatherInfo();
    const dateString = getFormattedDateClient();
    const Info = {
      time: GetCurrentTime(),
      date: dateString,
      weather: weatherInfo.weather,
      wind: weatherInfo.windSpeed
    };
    SendReactMessage('updateInfo', Info);
    
    //? Cache weather data
    const globalState = (globalThis as any).GlobalState;
    lastTimeData = globalState?.currentTime ? { ...globalState.currentTime } : null;
    lastWeatherData = globalState?.weather ? { ...globalState.weather } : null;
    
    //? Start the update cycle loop
    scheduleNextUpdate();
  }
  //? If UI becomes hidden, stop the update cycle and clear cached data
  else if (!visible && wasVisible) {
    if (updateTimeoutId) {
      clearTimeout(updateTimeoutId);
      updateTimeoutId = null;
    }
    lastTimeData = null;
    lastWeatherData = null;
  }
}

//! Update cycle loop
let updateTimeoutId: any = null;
let lastTimeData: any = null;
let lastWeatherData: any = null;
let hasPlayerSpawned = false;

function scheduleNextUpdate() {
  //? Player already spawned, return.
  if (hasPlayerSpawned) {
    return;
  }
  
  //? Clear any existing timeout
  if (updateTimeoutId) {
    clearTimeout(updateTimeoutId);
    updateTimeoutId = null;
  }
  
  //? If UI is not visible, return out and do not update.
  if (!isSpawnInterfaceVisible) {
    return;
  }
  
  //? Update timer in milliseconds. 5 seconds is fine.
  const updateInterval = 5000;
  
  updateTimeoutId = setTimeout(() => {
    //? A check just incase the player spawns before the timeout fires
    if (hasPlayerSpawned || !isSpawnInterfaceVisible) {
      return;
    }

    //? Get current statebag weather data
    const globalState = (globalThis as any).GlobalState;
    const currentTimeData = globalState?.currentTime;
    const currentWeatherData = globalState?.weather;

    //? Compre time and weather data to see if anything changed
    const timeChanged = !lastTimeData || 
      lastTimeData.hour !== currentTimeData?.hour || 
      lastTimeData.minute !== currentTimeData?.minute;

    const weatherChanged = !lastWeatherData || 
      lastWeatherData.weather !== currentWeatherData?.weather || 
      lastWeatherData.windSpeed !== currentWeatherData?.windSpeed;

    //? If anything changed, send updated info to React
    if (timeChanged || weatherChanged) {
      const weatherInfo = GetCurrentWeatherInfo();
      const timeStr = GetCurrentTime();
      const dateString = getFormattedDateClient();

      const Info = {
        time: timeStr,
        date: dateString,
        weather: weatherInfo.weather,
        wind: weatherInfo.windSpeed
      };
      SendReactMessage('updateInfo', Info);
      //? Update cached data
      lastTimeData = currentTimeData ? { ...currentTimeData } : null;
      lastWeatherData = currentWeatherData ? { ...currentWeatherData } : null;
    }

    //? Schedule the next update if player hasn't spawned
    if (!hasPlayerSpawned) {
      scheduleNextUpdate();
    }
  }, updateInterval);
}

function cleanupSpawnSystem() {
  //? Set player spawned
  hasPlayerSpawned = true;
  
  //? Clear any running timers
  if (updateTimeoutId) {
    clearTimeout(updateTimeoutId);
    updateTimeoutId = null;
  }
  
  //? Clear cached data
  lastTimeData = null;
  lastWeatherData = null;
  
  //? Mark interface as not visible
  isSpawnInterfaceVisible = false;
  
  console.log('[hof-spawn] cleanupSpawnSystem called.');
}


function getFormattedDateClient(): string {
  const currentDate = new Date();
  const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  
  const day = days[currentDate.getDay()];
  const month = months[currentDate.getMonth()];
  const dayOfMonth = currentDate.getDate();
  
  return `${day}, ${month} ${dayOfMonth}`;
}

//? NUI Callbacks
RegisterNuiCallback('hideFrame', (data: any, cb: (data: any) => void) => {
  ToggleNuiFrame(false);
  cb({});
});
RegisterNuiCallback('spawnCharacter', (data: any, cb: (data: any) => void) => {
  let CamPos: {x: number, y: number, z: number};
  let PlayerData: any = null;
  
  if (QBCore) {
    PlayerData = QBCore.Functions.GetPlayerData();
  }
  
  const IsDead = PlayerData.metadata.isDead || PlayerData.metadata.inLaststand;
  
  if (IsDead && Config.ForceLastLocation) {
    if (LastLocation) {
      CamPos = { x: PlayerData?.position?.x || LastLocation.x, y: PlayerData?.position?.y || LastLocation.y, z: PlayerData?.position?.z || LastLocation.z };
    } else {
      CamPos = { x: -206.19, y: -1013.78, z: 30.13 };
    }
      lib.notify({
        title: 'Spawned Last Location',
        description: 'Since you are uncon, you have been forced to your last location!',
        type: 'inform'
      });
  } else {
    if (data.label === 'Last Location') {
      if (LastLocation) {
        CamPos = { x: PlayerData?.position?.x || LastLocation.x, y: PlayerData?.position?.y || LastLocation.y, z: PlayerData?.position?.z || LastLocation.z };
      } else {
        CamPos = { x: -206.19, y: -1013.78, z: 30.13 };
      }
    } else {
      CamPos = { x: data.x, y: data.y, z: data.z };
    }
  }
  
  ToggleNuiFrame(false);
  
  //? Run our camera transition
  SetupCameraTransition(CamPos);
  
  // ? Set clothing after spawn
  if (PlayerData) {
    //? Slight delay for transition
    setTimeout(() => {
      TriggerEvent('qb-clothing:client:loadPlayerClothing', PlayerData.citizenid);
    }, 2500);
  }
  
  //? Run cleanup after spawn
  cleanupSpawnSystem();
  
  cb({});
});
RegisterNuiCallback('getPlayerProperties', async (data: null, cb: (data: unknown) => void) => {
  try {
    //? multichar handles init-ing players and logging in, but we're still going to check
    let isLoggedIn = LocalPlayer.state.isLoggedIn;

    
    if (!isLoggedIn) {
      console.log('[hof-spawn] Player isLoggedIn check failed.');
      SendReactMessage('propertyLoadError', 'Player login still initializing');
      cb({});
      return;
    }
    
    //? Fetch player's owned properties via nolag_properties export
    let properties = [];
    const exportsTable = (globalThis as any).exports;
    if (exportsTable && exportsTable['nolag_properties']) {
      const propertiesDataPromise = exportsTable['nolag_properties'].GetAllProperties('user');
      console.log('[hof-spawn] Properties promise:', propertiesDataPromise);
      
      //? Await the promise
      const propertiesData = await propertiesDataPromise;
      console.log('[hof-spawn] Properties data:', propertiesData);
      
      if (propertiesData) {
        if (Array.isArray(propertiesData)) {
          properties = propertiesData;
        } else if (typeof propertiesData === 'object') {
          properties = propertiesData.properties || propertiesData.data || Object.values(propertiesData) || [];
        }
      }
    } else {
      console.warn('[hof-spawn] nolag_properties export not found');
      SendReactMessage('propertyLoadError', 'Property system not available');
      cb({});
      return;
    }
    
    console.log('[hof-spawn] Properties array:', properties);
    //? Send properties back to NUI
    SendReactMessage('setPlayerProperties', properties);
    cb({});
  } catch (error) {
    console.error('[hof-spawn] Error getting player properties:', error);
    SendReactMessage('propertyLoadError', `Failed to load properties: ${error}`);
    cb({});
  }
});
RegisterNuiCallback('spawnAtProperty', (data: { id: number }, cb: (data: unknown) => void) => {
  try {
    console.log('[hof-spawn] Attempting to spawn at property ID:', data.id);
    
    //? Hide NUI
    ToggleNuiFrame(false);
    
    //? Do fade out transition
    DoScreenFadeOut(1000);
    
    setTimeout(() => {
      //? Wrap into the property
      const exportsTable = (globalThis as any).exports;
      if (exportsTable && exportsTable['nolag_properties']) {
        const result = exportsTable['nolag_properties'].WrapIntoProperty(data.id);
        console.log('[hof-spawn] WrapIntoProperty result:', result);
      } else {
        console.error('[hof-spawn] nolag_properties export not found for spawning');
      }
      
      //? disable scripted cameras
      RenderScriptCams(false, false, 1, true, true);
      
      //? Wait for property warp to complete, then fade in
      setTimeout(() => {
        DoScreenFadeIn(1500);
        
        //? Trigger clothing events
        TriggerEvent('qb-clothing:client:loadPlayerClothing');
      }, 500);
      
      //? Clean shit up
      cleanupSpawnSystem();
    }, 1000);
    
    cb({});
  } catch (error) {
    console.error('[hof-spawn] Error spawning at property:', error);
    //? Ensure camera is reset even on error
    RenderScriptCams(false, false, 1, true, true);
    DoScreenFadeIn(1000);
    cb({});
  }
});


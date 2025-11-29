import { useState, useEffect } from 'react';
import { Container, Flex, MantineProvider, createTheme } from '@mantine/core';
import { isEnvBrowser } from './utils/misc';
import { useNuiEvent } from './hooks/useNuiEvent';
import { LocationInterface, InfoData } from './types/index';
import SpawnInfo from './components/SpawnInfo';
import MapComponent from './components/MapComponent';
import LocationPins from './components/LocationPins';
import SpawnDecision from './components/SpawnDecision';
import LastLocationButton from './components/LastLocationButton';
import InformationPanel from './components/InformationPanel';
import PlayerHouses from './components/PlayerHouses';
import Logo from './components/Logo';
import { debugData } from './utils/debugData';

// Debug data for development
debugData([
  {
    action: 'setVisible',
    data: true
  } 
], 1000);

//? Theming
const theme = createTheme({
  colors: {
    dark: [
      '#C1C2C5',
      '#A6A7AB', 
      '#909296',
      '#5c5f66',
      '#373A40',
      '#2c2e33', // surface-bg
      '#25262b', // secondary-bg
      '#1A1B1E',
      '#1a1b1e', // primary-bg
      '#101113'
    ]
  },
  other: {
    mapScale: 1,
  },
  primaryColor: 'blue',
  fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
  //? Override default Mantine backgrounds
  components: {
    Container: {
      defaultProps: {
        style: { backgroundColor: 'transparent' }
      }
    }
  }
});

function App() {
  const [visible, setVisible] = useState(isEnvBrowser());
  const [spawnDecisionVisible, setSpawnDecisionVisible] = useState(false);
  const [chosenData, setChosenData] = useState({ label: '', x: 0, y: 0, z: 0 });
  const [infoData, setInfoData] = useState<InfoData>({
    time: '10:00 AM',
    date: 'Saturday, August 31',
    weather: 'Sunny',
    wind: 5,
  });
  const [locations, setLocations] = useState<LocationInterface[]>(isEnvBrowser() ? [
    {
      top: 85.03,
      left: 75.51,
      label: "Pier",
      type: "general",
      x: -1672.06,
      y: -1125.8,
      z: 13.06
    },
    {
      top: 63.48,
      left: 74.12,
      label: "Apartments",
      type: "housing",
      x: -589.4,
      y: -702.06,
      z: 36.29
    },
    {
      top: 48.48,
      left: 75.5,
      label: "Mission Row Police Department",
      type: "police",
      x: -589.4,
      y: -702.06,
      z: 36.29
    },
    {
      top: 29.5,
      left: 46.7,
      label: "Boilingbroke Penitentiary",
      type: "prison",
      x: -589.4,
      y: -702.06,
      z: 36.29
    },
    {
      top: 65.66,
      left: 65.91,
      label: "Hospital",
      type: "hospital",
      x: -1284.2755,
      y: 297.2698,
      z: 63.9412
    },
    {
      top: 26.07,
      left: 37.60,
      label: "Sandy Shores",
      type: "general",
      x: 1850.6030,
      y: 2585.9392,
      z: 44.6720
    },
    {
      top: 55.37,
      left: 13.97,
      label: "Paleto Bay",
      type: "general",
      x: 1879.6237,
      y: 3727.2805,
      z: 31.8428
    },
    {
      top: 36.48,
      left: 72.12,
      label: "Mirror Park",
      type: "general",
      x: 132.6796,
      y: 6636.1045,
      z: 30.7960
    }
  ] as unknown as LocationInterface[] : []);

  //? Initialize responsive scaling
  useEffect(() => {
    if (!visible) return; //? Don't run when not visible
    
    const updateScaleFactor = () => {
      const scaleFactor = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
      document.documentElement.style.setProperty('--scale-factor', scaleFactor.toString());
    };

    updateScaleFactor();
    window.addEventListener('resize', updateScaleFactor);
    return () => window.removeEventListener('resize', updateScaleFactor);
  }, [visible]); //? Only run when visibility changes

  useNuiEvent('setVisible', (data: boolean) => {
    setVisible(data);
    
    //? Direct DOM control
    const root = document.getElementById('root');
    const body = document.body;
    const html = document.documentElement;
    
    if (data === false) {
      //? hide all elements
      if (root) {
        root.style.display = 'none';
        root.style.visibility = 'hidden';
        root.style.opacity = '0';
      }
      if (body) {
        body.style.display = 'none';
        body.style.visibility = 'hidden';
        body.style.opacity = '0';
      }
      if (html) {
        html.style.display = 'none';
        html.style.visibility = 'hidden';
        html.style.opacity = '0';
      }
    } else {
      //? Restore elements
      if (root) {
        root.style.display = 'block';
        root.style.visibility = 'visible';
        root.style.opacity = '1';
      }
      if (body) {
        body.style.display = 'block';
        body.style.visibility = 'visible';
        body.style.opacity = '1';
      }
      if (html) {
        html.style.display = 'block';
        html.style.visibility = 'visible';
        html.style.opacity = '1';
      }
    }
  });
  useNuiEvent('setLocations', (data: LocationInterface[]) => {
    setLocations(data);
  });
  useNuiEvent('updateInfo', (data: InfoData) => setInfoData(data));
  
  const handleLastLocation = () => {
    setChosenData({ label: 'Last Location', x: 0, y: 0, z: 0 });
    setSpawnDecisionVisible(true);
  };

  if (!visible) {
    document.body.style.display = 'none';
    document.body.style.visibility = 'hidden';
    document.body.style.opacity = '0';
    
    const root = document.getElementById('root');
    if (root) {
      root.style.display = 'none';
      root.style.visibility = 'hidden';
      root.style.opacity = '0';
    }
    
    return null;
  }

  //? Ensure body is visible when UI is supposed to be shown
  document.body.style.display = 'block';
  document.body.style.visibility = 'visible';
  document.body.style.opacity = '1';
  
  const root = document.getElementById('root');
  if (root) {
    root.style.display = 'block';
    root.style.visibility = 'visible';
    root.style.opacity = '1';
  }

  return (
    <MantineProvider 
      theme={theme} 
      defaultColorScheme="dark"
      forceColorScheme="dark"
    >
      <Container
        fluid
        p={0}
        style={{
          height: '100vh',
          width: '100vw',
          position: 'relative',
          background: 'transparent',
          pointerEvents: visible ? 'auto' : 'none',
        }}
      >
        <Flex
          direction="column"
          align="center"
          justify="center"
          h="100vh"
          w="100vw"
          pos="relative"
        >
          <Logo />
          <SpawnInfo text="CHOOSE A SPAWN LOCATION" />
          <InformationPanel {...infoData} />
          <MapComponent />
          <LocationPins 
            locations={locations} 
            setVisible={setSpawnDecisionVisible}
            setChosenData={setChosenData}
          />
          <PlayerHouses visible={visible} />
          <SpawnDecision
            visible={spawnDecisionVisible}
            chosenData={chosenData}
            setVisible={setSpawnDecisionVisible}
            setChosenData={setChosenData}
          />
          <LastLocationButton onClick={handleLastLocation} />
        </Flex>
      </Container>
    </MantineProvider>
  );
}

export default App;

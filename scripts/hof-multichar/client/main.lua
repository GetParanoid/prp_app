local config = require 'config.client'
local defaultSpawn = require 'config.shared'.defaultSpawn

local previewCam
local randomLocation

local function refreshRandomLocation()
    local locations = config.characters.locations
    randomLocation = locations[math.random(1, #locations)]
    return randomLocation
end

local function applyPedAppearance(model, appearance)
    lib.requestModel(model, config.loadingModelsTimeout)
    SetPlayerModel(cache.playerId, model)
    if appearance then
        pcall(function()
            exports['illenium-appearance']:setPedAppearance(PlayerPedId(), appearance)
        end)
    end
    SetModelAsNoLongerNeeded(model)
end

refreshRandomLocation()

local randomPeds = {
    {
        model = `mp_m_freemode_01`,
        headOverlays = {
            beard = {color = 0, style = 0, secondColor = 0, opacity = 1},
            complexion = {color = 0, style = 0, secondColor = 0, opacity = 0},
            bodyBlemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
            blush = {color = 0, style = 0, secondColor = 0, opacity = 0},
            lipstick = {color = 0, style = 0, secondColor = 0, opacity = 0},
            blemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
            eyebrows = {color = 0, style = 0, secondColor = 0, opacity = 1},
            makeUp = {color = 0, style = 0, secondColor = 0, opacity = 0},
            sunDamage = {color = 0, style = 0, secondColor = 0, opacity = 0},
            moleAndFreckles = {color = 0, style = 0, secondColor = 0, opacity = 0},
            chestHair = {color = 0, style = 0, secondColor = 0, opacity = 1},
            ageing = {color = 0, style = 0, secondColor = 0, opacity = 1},
        },
        components = {
            {texture = 0, drawable = 0, component_id = 0},
            {texture = 0, drawable = 0, component_id = 1},
            {texture = 0, drawable = 0, component_id = 2},
            {texture = 0, drawable = 0, component_id = 5},
            {texture = 0, drawable = 0, component_id = 7},
            {texture = 0, drawable = 0, component_id = 9},
            {texture = 0, drawable = 0, component_id = 10},
            {texture = 0, drawable = 15, component_id = 11},
            {texture = 0, drawable = 15, component_id = 8},
            {texture = 0, drawable = 15, component_id = 3},
            {texture = 0, drawable = 34, component_id = 6},
            {texture = 0, drawable = 61, component_id = 4},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = -1},
            {prop_id = 1, drawable = -1, texture = -1},
            {prop_id = 2, drawable = -1, texture = -1},
            {prop_id = 6, drawable = -1, texture = -1},
            {prop_id = 7, drawable = -1, texture = -1},
        }
    },
    {
        model = `mp_f_freemode_01`,
        headBlend = {
            shapeMix = 0.3,
            skinFirst = 0,
            shapeFirst = 31,
            skinSecond = 0,
            shapeSecond = 0,
            skinMix = 0,
            thirdMix = 0,
            shapeThird = 0,
            skinThird = 0,
        },
        hair = {
            color = 0,
            style = 15,
            texture = 0,
            highlight = 0
        },
        headOverlays = {
            chestHair = {secondColor = 0, opacity = 0, color = 0, style = 0},
            bodyBlemishes = {secondColor = 0, opacity = 0, color = 0, style = 0},
            beard = {secondColor = 0, opacity = 0, color = 0, style = 0},
            lipstick = {secondColor = 0, opacity = 0, color = 0, style = 0},
            complexion = {secondColor = 0, opacity = 0, color = 0, style = 0},
            blemishes = {secondColor = 0, opacity = 0, color = 0, style = 0},
            moleAndFreckles = {secondColor = 0, opacity = 0, color = 0, style = 0},
            makeUp = {secondColor = 0, opacity = 0, color = 0, style = 0},
            ageing = {secondColor = 0, opacity = 1, color = 0, style = 0},
            eyebrows = {secondColor = 0, opacity = 1, color = 0, style = 0},
            blush = {secondColor = 0, opacity = 0, color = 0, style = 0},
            sunDamage = {secondColor = 0, opacity = 0, color = 0, style = 0},
        },
        components = {
            {drawable = 0, component_id = 0, texture = 0},
            {drawable = 0, component_id = 1, texture = 0},
            {drawable = 0, component_id = 2, texture = 0},
            {drawable = 0, component_id = 5, texture = 0},
            {drawable = 0, component_id = 7, texture = 0},
            {drawable = 0, component_id = 9, texture = 0},
            {drawable = 0, component_id = 10, texture = 0},
            {drawable = 15, component_id = 3, texture = 0},
            {drawable = 15, component_id = 11, texture = 3},
            {drawable = 14, component_id = 8, texture = 0},
            {drawable = 15, component_id = 4, texture = 3},
            {drawable = 35, component_id = 6, texture = 0},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = -1},
            {prop_id = 1, drawable = -1, texture = -1},
            {prop_id = 2, drawable = -1, texture = -1},
            {prop_id = 6, drawable = -1, texture = -1},
            {prop_id = 7, drawable = -1, texture = -1},
        }
    }
}

local function setupPreviewCam()
    DoScreenFadeIn(1000)
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
    FreezeEntityPosition(cache.ped, false)
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', randomLocation.camCoords.x, randomLocation.camCoords.y, randomLocation.camCoords.z, -6.0, 0.0, randomLocation.camCoords.w, 40.0, false, 0)
    SetCamActive(previewCam, true)
    SetCamUseShallowDofMode(previewCam, true)
    SetCamNearDof(previewCam, 0.4)
    SetCamFarDof(previewCam, 1.8)
    SetCamDofStrength(previewCam, 0.7)
    RenderScriptCams(true, false, 1, true, true)
    CreateThread(function()
        while DoesCamExist(previewCam) do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

local function destroyPreviewCam()
    if not previewCam then return end

    SetTimecycleModifier('default')
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(cache.ped, false)
end

local function randomPedFallback()
    -- Fallback to a default random ped
    local ped = randomPeds[math.random(1, #randomPeds)]
    applyPedAppearance(ped.model, ped)
end

local function previewPed(citizenId)
    if not citizenId then
        randomPedFallback()
        return
    end

    local clothing, model = lib.callback.await('hof-multichar:server:getPreviewPedData', false, citizenId)
    if not model or not clothing then
        randomPedFallback()
        return
    end

    applyPedAppearance(model, json.decode(clothing))
end

local function previewRandomCharacter(playerCharacters)
    if not playerCharacters or #playerCharacters == 0 then
        randomPedFallback()
        return
    end

    local availableCharacters = {}
    for i = 1, #playerCharacters do
        local character = playerCharacters[i]
        if character and character.citizenid then
            availableCharacters[#availableCharacters + 1] = character
        end
    end

    if #availableCharacters == 0 then
        randomPedFallback()
        return
    end

    local randomChar = availableCharacters[math.random(1, #availableCharacters)]
    previewPed(randomChar.citizenid)
end

local function firePlayerLoadedEvents()
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
end

local function capString(str)
  return str:gsub("(%w)([%w']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

local function onSubmit()
    -- TODO: They saved and created their character's clothing
        --TODO: This is where we should open the new player UI and/or start the tutorial or whatever
    lib.print.info('onSubmit')
end
local function onCancel()
    -- TODO: Notify if they accidentally pressed cancel
        --TODO: Ask if they would like to restart the character creation process since they canceled out
    lib.print.info('onCancel')
end

local function spawnNewCharacter(cid)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    -- destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = defaultSpawn.x,
        y = defaultSpawn.y,
        z = defaultSpawn.z,
        heading = defaultSpawn.w
    }) end)

    firePlayerLoadedEvents()
    while not LocalPlayer.state['isLoggedIn'] do
        Wait(250)
    end
    local props = exports.nolag_properties:GetAllProperties('user')
    print('props', json.encode(props, {indent = true}))
    for k,v in pairs(props) do
        exports.nolag_properties:WrapIntoProperty(v.id)
        Wait(250)
    end

    destroyPreviewCam()
    while not IsScreenFadedIn() do
        Wait(0)
    end
    TriggerEvent('qb-clothes:client:CreateFirstCharacter', onSubmit, onCancel)
end



local function createCharacter(cid, character)
  randomPedFallback() -- Use fallback random ped for character creation

  DoScreenFadeOut(150)
  local newData = lib.callback.await('hof-multichar:server:createCharacter', false, {
    firstname = capString(character.firstName),
    lastname = capString(character.lastName),
    nationality = capString(character.nationality),
    gender = character.gender == 'Male' and 0 or 1,
    birthdate = character.birthdate,
    cid = cid
  })
  CreateThread(function()
    lib.callback.await('base:server:SetupNewPlayer')
  end)
  spawnNewCharacter(cid)
  destroyPreviewCam()
  return true
end

local function chooseCharacter()
    refreshRandomLocation()
    SetFollowPedCamViewMode(2)

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

	FreezeEntityPosition(cache.ped, true)
	Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)
	lib.callback.await('hof-multichar:server:setCharBucket')
	Wait(1500)
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	setupPreviewCam()

	local characters, amount = lib.callback.await('hof-multichar:server:getCharacters')
	
    -- Use one of the player's characters as the preview ped
    previewRandomCharacter(characters)
	
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'showMultiChar',
		data = {
			characters = characters,
            allowedCharacters = amount
		}
	})

	SetTimecycleModifier('default')
end

RegisterNuiCallback('selectCharacter', function(data, cb)
  previewPed(data.citizenid)
  cb(1)
end)

RegisterNuiCallback('playCharacter', function(data, cb)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    lib.callback.await('hof-multichar:server:loadCharacter', false, data.citizenid)
    destroyPreviewCam()

    -- Fire all server and client events related to player loading
    firePlayerLoadedEvents()
    
    CreateThread(function()
        Wait(500) -- Give framework time to initialize
        TriggerEvent('hof-spawn:initInterface')
    end)

    cb(1)
end)

RegisterNuiCallback('deleteCharacter', function(data, cb)
  SetNuiFocus(false, false)
  TriggerServerEvent('hof-multichar:server:deleteCharacter', data.citizenid)
  destroyPreviewCam()
  chooseCharacter()
  cb(1)
end)

RegisterNuiCallback('createCharacter', function(data, cb)
  SetNuiFocus(false, false)
  local success = createCharacter(data.cid, data.character)
  if success then return end
  cb(success)
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
  if GetInvokingResource() then return end -- Make sure this can only be triggered from the server
  chooseCharacter()
end)


CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            chooseCharacter()
            break
        end
    end
    --? since people apparently die during char select and since SetEntityInvincible is notoriously unreliable, we'll just loop it to be safe. shrug
    while NetworkIsInTutorialSession() do
        SetEntityInvincible(PlayerPedId(), true)
        Wait(250)
    end
    SetEntityInvincible(PlayerPedId(), false)
end)
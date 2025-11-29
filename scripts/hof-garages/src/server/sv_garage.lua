local lib = exports.ox_lib

assert(lib.checkDependency('qbx_core', '1.19.0', true))
assert(lib.checkDependency('qbx_vehicles', '1.3.1', true))

local resource = GetCurrentResourceName()
local configContent = LoadResourceFile(resource, 'static/config.json')

local config = {}
if configContent then
    local ok, decoded = pcall(json.decode, configContent)
    if ok and type(decoded) == 'table' then
        config = decoded
    end
end

local debugEnabled = config.EnableDebugLogging == true

local function debugLog(...)
    if not debugEnabled then return end
    print(...)
end

local DEFAULT_ACCESS_POINT = 1

RegisterNetEvent('hof-garages:takeOutVehicleRequest')
AddEventHandler('hof-garages:takeOutVehicleRequest', function(vehicleId)
    local source = source
    debugLog('HOF-GARAGES: takeOutVehicleRequest event triggered')
    debugLog('HOF-GARAGES: source:', source, 'vehicleId:', tostring(vehicleId), 'type:', type(vehicleId))

    if not vehicleId then
        debugLog('HOF-GARAGES: vehicleId is nil!')
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'No vehicle ID provided' })
        return
    end

    local accessPoint = DEFAULT_ACCESS_POINT

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        debugLog('HOF-GARAGES: No player found for source:', source)
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Invalid player' })
        return
    end
    debugLog('HOF-GARAGES: Player validated')

    local vehicleData = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if not vehicleData then
        debugLog('HOF-GARAGES: Vehicle not found:', tostring(vehicleId))
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Vehicle not found' })
        return
    end

    local garageName = vehicleData.garage
    debugLog('HOF-GARAGES: Found vehicle in garage:', tostring(garageName))

    local garages = exports.qbx_garages:GetGarages()
    debugLog('HOF-GARAGES: Looking for garage:', tostring(garageName))

    local garage = garages[garageName]
    if not garage then
        debugLog('HOF-GARAGES: Garage not found:', tostring(garageName))
        debugLog('HOF-GARAGES: Available garages:')
        for name, _ in pairs(garages) do
            debugLog('  -', name)
        end
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Invalid garage' })
        return
    end
    debugLog('HOF-GARAGES: Found garage:', garage.label)

    debugLog('HOF-GARAGES: Using default access point:', accessPoint)

    if not garage.accessPoints or not garage.accessPoints[accessPoint] then
        debugLog('HOF-GARAGES: Invalid access point: ' .. tostring(accessPoint) .. ' for garage with ' .. tostring(#garage.accessPoints) .. ' access points')
        return { success = false, message = 'Invalid access point' }
    end

    if garage.groups and not exports.qbx_core:HasPrimaryGroup(source, garage.groups) then
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'No access to garage' })
        return
    end

    if vehicleData.citizenid ~= player['PlayerData'].citizenid then
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Vehicle not owned' })
        return
    end

    if vehicleData.state ~= 1 then
        debugLog('HOF-GARAGES: Vehicle state is:', tostring(vehicleData.state), 'expected: 1 (GARAGED)')
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Vehicle not available for takeout' })
        return
    end

    if vehicleData.garage ~= garageName then
        debugLog('HOF-GARAGES: Vehicle is in garage:', tostring(vehicleData.garage), 'but trying to access from:', tostring(garageName))
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Vehicle not in this garage' })
        return
    end

    local success, result = pcall(function()
        return exports.qbx_garages:spawnVehicle(source, vehicleId, garageName, accessPoint)
    end)

    if not success then
        debugLog('HOF-GARAGES: Error calling qbx_garages spawn:', result)
        TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, { success = false, message = 'Failed to call spawn function: ' .. tostring(result) })
        return
    end

    debugLog('HOF-GARAGES: Spawn function returned:', tostring(result), 'type:', type(result))

    local response
    if result and result ~= 0 then
        response = {
            success = true,
            message = 'Vehicle spawned successfully'
        }
        debugLog('HOF-GARAGES: Vehicle spawn SUCCESS - Network ID:', tostring(result))
    else
        response = {
            success = false,
            message = 'Failed to spawn vehicle - no space available or spawn error'
        }
        debugLog('HOF-GARAGES: Vehicle spawn FAILED - returned:', tostring(result))
    end

    TriggerClientEvent('hof-garages:takeOutVehicleResponse:' .. source, source, response)
end)

lib.callback.register('hof-garages:payDepotFee', function(source, vehicleId)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then 
        return { success = false, message = 'Invalid player' }
    end

    -- Get vehicle data
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if not playerVehicle then
        return { success = false, message = 'Vehicle not found' }
    end

    -- Validate ownership
    if playerVehicle.citizenid ~= player['PlayerData'].citizenid then
        return { success = false, message = 'Not your vehicle' }
    end

    -- Check if vehicle is actually in depot
    local garageType = exports.qbx_garages:GetGarageType(playerVehicle.garage)
    if garageType ~= 'depot' then
        return { success = false, message = 'Vehicle not in depot' }
    end

    -- Check if player has enough money
    local depotPrice = playerVehicle.depotPrice or 0
    if player['PlayerData'].money.cash < depotPrice then
        return { success = false, message = 'Insufficient funds' }
    end

    -- Remove money and update vehicle state
    player['Functions'].RemoveMoney('cash', depotPrice)
    
    -- Set vehicle as available for pickup
    local success = exports.qbx_garages:SetVehicleGarage(vehicleId, playerVehicle.garage)
    if success then
        exports.qbx_garages:SetVehicleDepotPrice(vehicleId, 0)
        return { success = true, message = 'Payment successful - vehicle available for pickup' }
    else
        -- Refund on failure
        player['Functions'].AddMoney('cash', depotPrice)
        return { success = false, message = 'Payment processing failed' }
    end
end)

RegisterNetEvent('hof-garages:server:openGarage', function(garageName, accessPoint)
    local source = source
    local player = exports.qbx_core:GetPlayer(source)

    debugLog('HOF-GARAGES: Received openGarage event from player', source, 'for garage', garageName, 'access point', accessPoint)

    if not player then 
        debugLog('HOF-GARAGES: No player found for source', source)
        return 
    end

    local garages = exports.qbx_garages:GetGarages()
    local garage = garages[garageName]
    if not garage then 
        debugLog('HOF-GARAGES: Garage not found:', garageName)
        return 
    end

    debugLog('HOF-GARAGES: Found garage:', garage.label)

    if not garage.accessPoints or not garage.accessPoints[accessPoint] then 
        debugLog('HOF-GARAGES: Invalid access point:', accessPoint)
        return 
    end

    debugLog('HOF-GARAGES: Access point validated')

    if garage.groups and not exports.qbx_core:HasPrimaryGroup(source, garage.groups) then
        exports['hof-base']:notify(source, {
            title = 'Error',
            description = 'You do not have access to this garage',
            type = 'error',
            duration = 5000
        })
        return
    end

    debugLog('HOF-GARAGES: Getting vehicles for garage:', garageName)
    
    local vehicles = exports.qbx_vehicles:GetPlayerVehicles({
        citizenid = player['PlayerData'].citizenid,
        garage = garageName
    })
    
    if not vehicles or #vehicles == 0 then
        debugLog('HOF-GARAGES: No vehicles found for garage:', garageName)
        exports['hof-base']:notify(source, {
            title = 'Error',
            description = 'No vehicles found',
            type = 'error',
            duration = 5000
        })
        return
    end

    debugLog('HOF-GARAGES: Found', #vehicles, 'vehicles, sending to client')

    TriggerClientEvent('hof-garages:client:openGarageUI', source, {
        garageName = garageName,
        garageInfo = garage,
        vehicles = vehicles,
        accessPoint = accessPoint
    })

    debugLog('HOF-GARAGES: Sent garage UI data to client')
end)

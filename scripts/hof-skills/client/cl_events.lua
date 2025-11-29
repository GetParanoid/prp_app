---@diagnostic disable: undefined-global

local ClientMenu = require('client.cl_menu')
local ClientFunctions = require('client.cl_functions')

local isLoggedIn = false


-- Detect player login
AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, loginState)
    lib.print.info("isLoggedIn State Updated", loginState)
    if isLoggedIn == loginState then return end
    isLoggedIn = loginState

    if isLoggedIn then
        TriggerServerEvent('_skills:sv:InitPlayerMetadata')
    end
end)


-- NetEvent to open skills menu
RegisterNetEvent('_skills:cl:OpenSkillsMenu', ClientMenu.OpenSkillsMenu)

--! Notification Events and functions

RegisterNetEvent('skills:notification', ClientFunctions.HandleQueuedNotification)
RegisterNetEvent('skills:immediateNotification', ClientFunctions.HandleImmediateNotification)
-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
end)

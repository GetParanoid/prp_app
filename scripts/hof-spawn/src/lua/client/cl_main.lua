--! Client-side Lua wrapper for QBX/QBCORE

--? Compat wrappers
RegisterNetEvent('qb-spawn:client:setupSpawnUI', function()
    TriggerEvent('hof-spawn:initInterface')
end)

RegisterNetEvent('qb-spawn:client:openUI', function()
    TriggerEvent('hof-spawn:initInterface')
end)


local Hooks = require('server.sv_hooks')
while not CONFIG_INIT do Wait(500) end


local xpGain = Hooks.Functions.RegisterHook('xpGain', function(payload)
    TriggerClientEvent('skills:notification', payload.source, {
        type = 'xpGain',
        skills = payload.skills,
    })
end, 'notifications')
if not xpGain then lib.print.error('Failed to register XP Gain Notification Hook') end


local xpLoss = Hooks.Functions.RegisterHook('xpLoss', function(payload)
    TriggerClientEvent('skills:notification', payload.source, {
        type = 'xpLoss',
        skills = payload.skills,
    })
end, 'notifications')
if not xpLoss then lib.print.error('Failed to register XP Loss Notification Hook') end


local levelUp = Hooks.Functions.RegisterHook('levelUp', function(payload)
    TriggerClientEvent('skills:notification', payload.source, {
        type = 'levelUp',
        skills = payload.skills,
    })
end, 'notifications')
if not levelUp then lib.print.error('Failed to register Level Up Notification Hook') end


local levelDown = Hooks.Functions.RegisterHook('levelDown', function(payload)
    TriggerClientEvent('skills:notification', payload.source, {
        type = 'levelDown',
        skills = payload.skills,
    })
end, 'notifications')
if not levelDown then lib.print.error('Failed to register Level Down Notification Hook') end
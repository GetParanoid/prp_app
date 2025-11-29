local microtime = os.microtime

_G.SKILLS_HOOKS = _G.SKILLS_HOOKS or {
    xpGain = {},
    xpLoss = {},
    levelUp = {},
    levelDown = {},
    xpModification = {}
}

local HooksModule = {
    Hooks = _G.SKILLS_HOOKS
}


HooksModule.Functions = {
    -- Register a hook
    RegisterHook = function(eventName, callback, resourceOverride)
        if not HooksModule.Hooks[eventName] then
            lib.print.info('Invalid Event name: ' .. tostring(eventName))
            return nil, "Invalid event name"
        end
        if type(callback) == "table" and type(callback.__cfx_functionReference) == "string" then
            callback = callback
        elseif type(callback) ~= "function" then
            return nil, "Callback must be a function"
        end
        local hookID = #HooksModule.Hooks[eventName] + 1
        HooksModule.Hooks[eventName][hookID] = {
            callback = callback,
            resource = resourceOverride or GetInvokingResource()
        }
        lib.print.info(('Registered hook "%s:%s" with ID %d'):format(resourceOverride or GetInvokingResource(), eventName, hookID))
        return hookID
    end,
    -- Unregister a hook by its ID
    UnregisterHook = function(eventName, hookID)
        if HooksModule.Hooks[eventName] and HooksModule.Hooks[eventName][hookID] then
            HooksModule.Hooks[eventName][hookID] = nil
            lib.print.info(('Unregistered hook "%s:%s" with ID %d'):format(GetInvokingResource(), eventName, hookID))
            return true
        end
        return false
    end,
    -- Trigger a hook
    TriggerHook = function(eventName, payload)
        if HooksModule.Hooks[eventName] then
            for i = 1, #HooksModule.Hooks[eventName] do
                local hook = HooksModule.Hooks[eventName][i]
                if hook then
                    local start = microtime()
                    pcall(hook.callback, payload)
                    local executionTime = microtime() - start

                    if executionTime >= 100000 then
                        lib.print.info(('Execution of event hook "%s" took %.2fms.'):format(hook.resource, executionTime / 1e3))
                    end
                end
            end
        end
    end,
    ValidateXPModification = function(payload)
        if HooksModule.Hooks["xpModification"] then
            for hookID, hook in pairs(HooksModule.Hooks["xpModification"]) do

                local start = microtime()
                local _, result, reason = pcall(hook.callback, payload)
                local executionTime = microtime() - start

                if executionTime >= 100000 then
                    lib.print.info(('Execution of event hook "%s:%s:" took %.2fms.'):format(hook.resource, hook.callback, executionTime / 1e3))
                end

                if result == false then
                    return {validationPassed = false, reason = reason or "Unknown reason", hookID = hookID}
                end
            end
        end
        return {validationPassed = true}
    end,
}


-- Exported functions
exports("registerHook", HooksModule.Functions.RegisterHook)
exports("unregisterHook", HooksModule.Functions.UnregisterHook)
exports("triggerHook", HooksModule.Functions.TriggerHook)
exports("validateXPModification", HooksModule.Functions.ValidateXPModification)

return HooksModule

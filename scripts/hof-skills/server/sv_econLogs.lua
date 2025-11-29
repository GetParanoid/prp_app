local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local Logging = require('server.sv_logging')


--TODO: Not implemented yet. Probably will be removed in favor of Grafana dashboard.
local Functions = { EconLogs = { Database = {} } }

function Functions.EconLogs.Database.XPSource()
    local dbPromise = promise.new()

    MySQL.query('SELECT * FROM skills_xpsource_stats', {}, function(result)
        if not result or #result == 0 then
            dbPromise:resolve({})
            return
        end

        local formattedResults = {}
        for _, row in ipairs(result) do
            local xpData = json.decode(row.xp_data)
            formattedResults[row.xpSource] = {
                xpGain = xpData.xpGain or 0,
                xpLoss = xpData.xpLoss or 0,
                xpGainScaled = xpData.xpGainScaled or 0,
                xpLossScaled = xpData.xpLossScaled or 0
            }
        end

        dbPromise:resolve(formattedResults)
    end)

    return dbPromise
end

function Functions.EconLogs.Database.Skills()
    local dbPromise = promise.new()

    MySQL.query('SELECT * FROM skills_stats', {}, function(result)
        if not result or #result == 0 then
            dbPromise:resolve({})
            return
        end

        local formattedResults = {}
        for _, row in ipairs(result) do
            local xpData = json.decode(row.xp_data)
            formattedResults[row.skill] = {
                xpGain = xpData.xpGain or 0,
                xpLoss = xpData.xpLoss or 0,
                xpGainScaled = xpData.xpGainScaled or 0,
                xpLossScaled = xpData.xpLossScaled or 0
            }
        end

        dbPromise:resolve(formattedResults)
    end)

    return dbPromise
end

return {
    Functions = Functions
}
--[[
    Internal Events for Logging
    - skills:xpGain
    - skills:levelUp
    - skills:xpLoss
    - skills:levelDown
    - skills:skillReset
    - skills:InfoLog
        - tags (logType):
            info, warn, error, benchmark
--]]
local ServerConfig = require('config.server')

local Functions = { Util = {}, Loki = {}}
function Functions.Util.FormatTags(tagData)
    local formatParts = {}
    local values = {}

    -- Sort keys for consistent output (optional)
    local keys = {}
    for key in pairs(tagData) do
        table.insert(keys, key)
    end
    table.sort(keys)

    -- Build format parts and collect values
    for _, key in ipairs(keys) do
        local value = tagData[key]
        local formatSpecifier = type(value) == "number" and "%d" or "%s"

        table.insert(formatParts, key .. ":" .. formatSpecifier)
        table.insert(values, value)
    end

    -- Join format parts with commas and spaces
    local formatString = table.concat(formatParts, ",")

    -- Use string.format with table unpack to create the formatted string
    return string.format(formatString, table.unpack(values))
end


function Functions.Loki.SubmitLog(logData)
    if not ServerConfig.Logging.Loki.enabled then return end
    if not logData then lib.print.error('Functions.Loki.SubmitLog(): logData not provided') return end
    if not logData.logEvent then lib.print.error('Functions.Loki.SubmitLog(): logData.logEvent not provided') return end
    if not logData.logMessage then lib.print.error('Functions.Loki.SubmitLog(): logData.logMessage not provided') return end
    if not logData.logSource then lib.print.error('Functions.Loki.SubmitLog(): logData.logSource not provided') return end
    if not next(logData.logTags) then lib.print.error('Functions.Loki.SubmitLog(): logData.logTags not provided') return end
    local formattedTags = Functions.Util.FormatTags(logData.logTags)
    lib.logger(logData.logSource, logData.logEvent, logData.logMessage, formattedTags)
end
return {
    Functions = Functions,
}
--! Import Configs and Modules
local ClientConfig <const> = require "config.client"
local SharedConfig <const> = require "config.shared"
local originalTrace <const> = Citizen.Trace
local tablePack <const> = table.pack
local tableUnpack <const> = table.unpack

--! Set ERROR_EVENT as local constant
local ERROR_EVENT <const> = SharedConfig.ERROR_EVENT

local keywords = {}
for _, word in ipairs(ClientConfig.errorWords or {}) do
    if type(word) == "string" then
        keywords[#keywords + 1] = string.lower(word)
    end
end

local suppressTraceIntercept = false

local function traceLine(message)
    originalTrace(tostring(message))
end

local function shouldReportError(message)
    local lowered = string.lower(message)
    for i = 1, #keywords do
        if lowered:find(keywords[i], 1, true) then
            return true
        end
    end
    return false
end

local function reportClientError(args)
    local resourceName = GetCurrentResourceName()

    suppressTraceIntercept = true
    --? Trace/Print the error message to client F8 console.
    traceLine("----- RESOURCE ERROR -----")
    for i = 1, args.n do
        traceLine(args[i])
    end
    traceLine("------ PLEASE REPORT THIS TO STAFF ------")
    traceLine("------ IDEALLY WITH CLIPS & SCREENSHOTS OF WHAT YOU'RE DOING ------")
    suppressTraceIntercept = false

    TriggerServerEvent(ERROR_EVENT, resourceName, tableUnpack(args, 1, args.n))
end

---@diagnostic disable-next-line: duplicate-set-field
function Citizen.Trace(...)
    local args = tablePack(...)

    if suppressTraceIntercept then
        originalTrace(tableUnpack(args, 1, args.n))
        return
    end

    local message = args[1]
    if type(message) == "string" and shouldReportError(message) then
        reportClientError(args)
        return
    end

    originalTrace(tableUnpack(args, 1, args.n))
end
--! Import Configs and Modules
local ServerConfig <const> = require "config.server"
local SharedConfig <const> = require "config.shared"
local ServerFunctions <const> = require "server.sv_functions"
local DiscordLogger <const> = require "server.sv_logger"
local LokiLogger <const> = require "server.sv_loki"

--! Set ERROR_EVENT as local constant
local ERROR_EVENT <const> = SharedConfig.ERROR_EVENT

--! Logging setup
local LoggingConfig <const> = ServerConfig.Logging or {}

local function selectLogger()
    local backend = type(LoggingConfig.backend) == "string" and LoggingConfig.backend:lower() or "discord"

    if backend == "loki" then
        local config = LoggingConfig.loki or {}
        if config.enabled then
            return function(entry)
                LokiLogger.log(config, entry)
            end
        end
    end

    local config = LoggingConfig.discord or {}
    return function(entry)
        DiscordLogger.log(config, entry)
    end
end

local ActiveLogger <const> = selectLogger()



RegisterNetEvent(ERROR_EVENT, function(resource, ...)
    local src = source
    local args = table.pack(...)
    local playerData = ServerFunctions.GetPlayerData(src)
    local citizenId = playerData and playerData.citizenid or "UNKNOWN"
    local ped = GetPlayerPed(src)

    local x, y, z, heading = 0.0, 0.0, 0.0, 0.0
    if ped and ped ~= 0 then
        x, y, z = table.unpack(GetEntityCoords(ped))
        heading = GetEntityHeading(ped)
    end

    local errorMessage = ServerFunctions.SanitizeErrorArgs(args)
    if errorMessage == "" then
        errorMessage = "No error message supplied."
    end

    local steamProfile = ServerFunctions.SteamProfile(GetPlayerIdentifierByType(src, 'steam'))
    local discordMention = ServerFunctions.DiscordMention(GetPlayerIdentifierByType(src, 'discord'))
    local status = ServerFunctions.DeadOrLastStand(src)
    local identifiers = ServerFunctions.FetchIdentifiers(src)
    local coords = ServerFunctions.FormatCoords(x, y, z, heading)

    local message = table.concat({
        string.format("**__Script Error In %s__**", resource or "unknown"),
        "---------------------------------------",
        "**__Triggered By:__**",
        string.format("**Username:** %s", GetPlayerName(src) or "UNKNOWN"),
        string.format("**Steam Account:** %s", steamProfile),
        string.format("**Discord:** %s", discordMention),
        string.format("**Source(ID):** %s", src),
        string.format("**CitizenID:** %s", citizenId),
        string.format("**Coords:** %s", coords),
        string.format("**Status:** %s", status),
        string.format("**Identifiers:** %s", identifiers),
        "---------------------------------------",
        errorMessage,
        "---------------------------------------"
    }, "\n")

    ActiveLogger({
        source = citizenId,
        event = ERROR_EVENT,
        color = 16711680,
        message = message,
        level = "error",
        --? Grafana Tags
        tags = {
            resource = resource or "unknown",
            citizenid = citizenId,
            source_id = tostring(src),
            username = GetPlayerName(src) or "UNKNOWN",
        },
    })
end)
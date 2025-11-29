local QBX = exports.qbx_core

local Functions = {}

function Functions.FormatCoords(x, y, z, heading)
    if not x or not y or not z then
        return "Coords unavailable"
    end

    return string.format("%.2f, %.2f, %.2f, H: %.2f", x, y, z, heading or 0.0)
end

function Functions.FetchIdentifiers(source)
    if type(source) ~= "number" then
        return "\nIdentifiers unavailable"
    end

    local identifiers = GetPlayerIdentifiers(source)
    if type(identifiers) ~= "table" or #identifiers == 0 then
        return "\nIdentifiers unavailable"
    end

    return "\n" .. table.concat(identifiers, "\n")
end

function Functions.DeadOrLastStand(source)
    local player = QBX:GetPlayer(source)
    if not player or not player.PlayerData then
        return "Player state unavailable"
    end

    local metadata = player.PlayerData.metadata or {}
    if metadata.isDead then
        return "Player Dead"
    end

    if metadata.inLaststand then
        return "Player In Laststand"
    end

    return "Player Alive"
end

function Functions.SanitizeErrorArgs(args)
    if type(args) ~= "table" then
        return ""
    end

    local count = args.n or #args
    local messages = {}

    for index = 1, count do
        local value = args[index]
        if type(value) == "string" then
            messages[#messages + 1] = value:gsub("%^%d+", "")
        else
            messages[#messages + 1] = tostring(value)
        end
    end

    return table.concat(messages, "\n")
end

function Functions.SteamProfile(identifier)
    if type(identifier) ~= "string" then
        return "ERROR: STEAM-NOT-FOUND"
    end

    local hexId = identifier:gsub("steam:", "")
    local decimalId = tonumber(hexId, 16)
    if not decimalId then
        return "ERROR: STEAM-CONVERSION-FAILED"
    end

    return string.format("https://steamcommunity.com/profiles/%d", decimalId)
end

function Functions.DiscordMention(identifier)
    if type(identifier) ~= "string" then
        return "ERROR: DISCORD-NOT-FOUND"
    end

    local discordId = identifier:gsub("discord:", "")
    return string.format("<@%s>", discordId)
end

function Functions.GetPlayerData(sourceId)
    local player = QBX:GetPlayer(sourceId)
    if not player or not player.PlayerData then
        return nil
    end

    return player.PlayerData
end

return Functions
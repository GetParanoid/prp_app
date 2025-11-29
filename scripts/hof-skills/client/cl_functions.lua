local SharedFunctions = require('shared.sh_functions')
local Notifications = require('client.cl_notifications')


local function LevelPercentage(xp)
    -- TODO: When we have a Skill with MaxLevel less than 20, we need to change this to use the MaxLevel instead of 20/going off of XP
    -- TODO:    i.e Charisma should be 5, but we're using 20
    local level = SharedFunctions.XPToLevel(xp)
    if level >= #GlobalState.XP_TABLE then return 100 end
    local maxXP = GlobalState.XP_TABLE[level+1] or GlobalState.XP_TABLE[#GlobalState.XP_TABLE]
    local minXP = GlobalState.XP_TABLE[level]
    local percent = math.floor((xp - minXP) / (maxXP - minXP) * 100)
    return percent
end

local function ProgressionColor(xp)
    local percent = LevelPercentage(xp)
    return (percent >= 0 and percent <= 20 and "red") or
            (percent > 20 and percent <= 40 and "orange") or
            (percent > 40 and percent <= 70 and "yellow") or
            (percent > 70 and percent < 100 and "green") or
            (percent <= 100 and "purple") or
            "white" -- Default color
end

--! Notification functions
local function logInvalid(prefix, payload)
    lib.print.error(prefix, json.encode(payload or {}))
end

local function handleQueuedNotification(data)
    if not data or not data.type then
        logInvalid("Invalid notification data received:", data)
        return
    end

    if data.skills and type(data.skills) == 'table' then
        Notifications.Functions.ProcessMultiSkillNotification(data)
    elseif data.skill then
        Notifications.Functions.AccumulateNotification(data)
    else
        logInvalid("Invalid notification format - missing skill or skills data:", data)
    end
end

local function handleImmediateNotification(data)
    if not data or not data.type then
        logInvalid("Invalid immediate notification data received:", data)
        return
    end

    Notifications.Functions.ImmediateNotification(data)
end

return {
    ProgressionColor = ProgressionColor,
    LevelPercentage = LevelPercentage,
    HandleQueuedNotification = handleQueuedNotification,
    HandleImmediateNotification = handleImmediateNotification,
}
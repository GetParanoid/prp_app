
---@diagnostic disable: undefined-global

--! This file is almost entirely AI generated.
--!      I was too lazy to write a notfi queue system that did exactly what I wanted (Accumulative debouncing),
--!         but this works flawlessly, so :shrug:


if _G.SkillsNotificationInstance then
    return _G.SkillsNotificationInstance
end


local ClientConfig = require('config.client')
local NotificationSettings = ClientConfig.Settings.Notifications

local Functions = {}
local NotificationManager = {
    queue = {},              -- Queue of notifications ready to display
    isProcessing = false,    -- Flag to prevent concurrent processing
    accumulator = {},        -- Storage for accumulating notifications [type_skill] = {data, timer, firstTime}
}

local function createAccumulatorEntry(notificationType, timestamp)
    return {
        data = {
            type = notificationType,
            skills = {}
        },
        timer = nil,
        firstTime = timestamp or GetGameTimer()
    }
end

local function ensureSkillEntry(accumulator, incomingData)
    local skills = accumulator.data.skills
    if not skills[incomingData.skill] then
        skills[incomingData.skill] = {
            amount = 0,
            levelsGained = 0,
            levelsLost = 0,
            oldLevel = incomingData.oldLevel,
            newLevel = incomingData.newLevel
        }
    end

    return skills[incomingData.skill]
end

local function sumSkillField(skills, field)
    local total = 0
    for _, skillData in pairs(skills) do
        total = total + (skillData[field] or 0)
    end
    return total
end

local function countSkills(skills)
    local total = 0
    local firstSkill

    for skillName in pairs(skills) do
        total = total + 1
        firstSkill = firstSkill or skillName
    end

    return total, firstSkill
end

--[[
    Format Large Numbers

    Converts large numbers into readable format with K/M suffixes.

    @param num number - The number to format
    @return string - Formatted number string

    Examples:
    - 1500 -> "1.5K"
    - 1500000 -> "1.5M"
    - 150 -> "150"
--]]
local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end


--[[
    Build Notification Description

    Creates human-readable notification descriptions based on notification type
    and accumulated data. Handles both single and multi-skill notifications.

    @param notificationType string - Type of notification ('levelUp', 'levelDown', 'xpGain', 'xpLoss')
    @param data table - Notification data containing skill information
    @return string - Formatted description text
--]]
local function buildSkillNameList(skills)
    local names = {}
    for skillName in pairs(skills or {}) do
        names[#names + 1] = skillName
    end
    return table.concat(names, ', ')
end

local function buildLevelDescription(verb, data)
    if data.skillCount and data.skillCount > 1 then
        return ('You %s %d levels in **%s**!'):format(verb, data.totalLevels, buildSkillNameList(data.skills))
    end

    local skillName = data.skill or 'Unknown'
    if data.totalLevels and data.totalLevels > 1 then
        return ('You %s %d levels in **%s**!'):format(verb, data.totalLevels, skillName)
    end

    return ('You %s a level in **%s**!'):format(verb, skillName)
end

local function buildXpDescription(sign, header, data)
    if data.skillCount and data.skillCount > 1 then
        local breakdown = {}
        for skillName, skillData in pairs(data.skills) do
            breakdown[#breakdown + 1] = ('%s: %s%s'):format(skillName, sign, formatNumber(skillData.amount or 0))
        end
        return ('%s: %s'):format(header, table.concat(breakdown, ', '))
    end

    local xpAmount = data.totalAmount or data.amount or 0
    return ('%s%s XP in **%s**'):format(sign, formatNumber(xpAmount), data.skill or 'Unknown')
end

local DescriptionBuilders = {
    levelUp = function(data)
        return buildLevelDescription('gained', data)
    end,
    levelDown = function(data)
        return buildLevelDescription('lost', data)
    end,
    xpGain = function(data)
        return buildXpDescription('+', 'XP Gained', data)
    end,
    xpLoss = function(data)
        return buildXpDescription('-', 'XP Lost', data)
    end,
}

local AccumulationDelays = {
    levelUp = 500,
    levelDown = 500,
    xpGain = 1500,
    xpLoss = 1500,
}

local function buildIndividualNotification(typeName, skillName, skillData)
    local notification = {
        type = typeName,
        skill = skillName,
    }

    if typeName == 'xpGain' or typeName == 'xpLoss' then
        notification.amount = skillData
    elseif typeName == 'levelUp' then
        notification.levelsGained = skillData.levelsGained
        notification.oldLevel = skillData.oldLevel
        notification.newLevel = skillData.newLevel
    elseif typeName == 'levelDown' then
        notification.levelsLost = skillData.levelsLost
        notification.oldLevel = skillData.oldLevel
        notification.newLevel = skillData.newLevel
    end

    return notification
end

function Functions.BuildNotificationDescription(notificationType, data)
    local builder = DescriptionBuilders[notificationType]
    if builder then
        return builder(data)
    end

    return 'Skill updated!'
end

--[[
    Process Notification Queue

    Processes the notification queue sequentially to prevent UI spam.
    Displays one notification at a time with appropriate delays between them.

    This function is recursive and will continue processing until the queue is empty.
--]]
function Functions.ProcessNotificationQueue()
    -- Don't process if already processing or queue is empty
    if NotificationManager.isProcessing or #NotificationManager.queue == 0 then
        return
    end

    -- Set processing flag to prevent concurrent execution
    NotificationManager.isProcessing = true

    -- Get and remove the first notification from queue
    local notification = table.remove(NotificationManager.queue, 1)

    -- Display the notification using ox_lib
    lib.notify(notification)
    if notification.sound.enabled then
        PlaySoundFrontend(-1, notification.sound.name, notification.sound.set, true)
    end

    -- Schedule next notification processing after display time + buffer
    SetTimeout(NotificationSettings.Settings.displayTime + 200, function()
        NotificationManager.isProcessing = false
        Functions.ProcessNotificationQueue() -- Recursively process next notification
    end)
end

--[[
    Create and Queue Notification

    Creates a formatted notification from data and adds it to the display queue.
    Manages queue size to prevent memory issues.

    @param data table - Notification data
        - type: Notification type
        - skill: Skill name (optional for multi-skill)
        - amount/levelsGained/levelsLost: Relevant values
--]]
function Functions.CreateAndQueueNotification(data)
    if not data or not data.type then return end

    local template = NotificationSettings.Templates[data.type]
    if not template then return end

    -- Create notification object
    local notification = {
        id = data.type .. '_' .. (data.skill or 'multi') .. '_' .. GetGameTimer(),
        title = template.title,
        description = Functions.BuildNotificationDescription(data.type, data),
        type = template.type,
        duration = template.duration,
        icon = template.icon,
        iconAnimation = 'beatFade',
        position = template.position,
        sound = {
            enabled = template.sound.enabled,
            set = template.sound.set,
            name = template.sound.name,
        },
    }

    -- Manage queue size to prevent overflow
    -- if #NotificationManager.queue >= (NotificationSettings.Settings.maxQueueSize or 5) then
    --     table.remove(NotificationManager.queue, 1) -- Remove oldest notification
    -- end

    -- Add to queue and start processing
    table.insert(NotificationManager.queue, notification)
    Functions.ProcessNotificationQueue()
end

--[[
    Flush Accumulator

    Processes and sends accumulated notifications for a specific key.
    Consolidates multiple similar notifications into a single display.

    @param key string - Accumulator key (format: "type_skill")
--]]
function Functions.FlushAccumulator(key)
    local accumulator = NotificationManager.accumulator[key]
    if not accumulator then return end

    -- Clear the timer to prevent duplicate processing
    if accumulator.timer then
        ClearTimeout(accumulator.timer)
    end

    local data = accumulator.data
    local skillCount, firstSkill = countSkills(data.skills)
    if skillCount == 0 then
        NotificationManager.accumulator[key] = nil
        return
    end

    -- Build final notification data structure
    local finalData = {
        type = data.type
    }

    if skillCount == 1 then
        finalData.skill = firstSkill
        local skillData = data.skills[firstSkill]

        if data.type == 'xpGain' or data.type == 'xpLoss' then
            finalData.amount = skillData.amount
        elseif data.type == 'levelUp' then
            finalData.levelsGained = skillData.levelsGained
            finalData.oldLevel = skillData.oldLevel
            finalData.newLevel = skillData.newLevel
        elseif data.type == 'levelDown' then
            finalData.levelsLost = skillData.levelsLost
            finalData.oldLevel = skillData.oldLevel
            finalData.newLevel = skillData.newLevel
        end
    else
        finalData.skillCount = skillCount
        finalData.skills = data.skills

        if data.type == 'xpGain' or data.type == 'xpLoss' then
            finalData.totalAmount = sumSkillField(data.skills, 'amount')
        elseif data.type == 'levelUp' then
            finalData.totalLevels = sumSkillField(data.skills, 'levelsGained')
        elseif data.type == 'levelDown' then
            finalData.totalLevels = sumSkillField(data.skills, 'levelsLost')
        end
    end

    -- Create and queue the consolidated notification
    Functions.CreateAndQueueNotification(finalData)

    -- Clean up the accumulator
    NotificationManager.accumulator[key] = nil
end

--[[
    Accumulate Notification

    Main accumulation function that handles incoming notification data.
    Implements intelligent debouncing by combining similar notifications
    over time periods to reduce spam while preserving information.

    @param incomingData table - Raw notification data from server
        - type: Notification type
        - skill: Skill name
        - amount: XP amount (for XP notifications)
        - levelsGained/levelsLost: Level changes
--]]
function Functions.AccumulateNotification(incomingData)
    if not incomingData or not incomingData.type or not incomingData.skill then
        return
    end

    local key = incomingData.type .. '_' .. incomingData.skill
    local currentTime = GetGameTimer()
    local accumulator = NotificationManager.accumulator[key]

    if not accumulator then
        accumulator = createAccumulatorEntry(incomingData.type, currentTime)
        NotificationManager.accumulator[key] = accumulator
    end

    local maxAccumulateTime = NotificationSettings.Settings.maxAccumulateTime or 5000
    if (currentTime - accumulator.firstTime) >= maxAccumulateTime then
        Functions.FlushAccumulator(key)
        accumulator = createAccumulatorEntry(incomingData.type, currentTime)
        NotificationManager.accumulator[key] = accumulator
    end

    local skillData = ensureSkillEntry(accumulator, incomingData)

    if incomingData.type == 'xpGain' or incomingData.type == 'xpLoss' then
        skillData.amount = skillData.amount + (incomingData.amount or 0)
    elseif incomingData.type == 'levelUp' then
        skillData.levelsGained = skillData.levelsGained + (incomingData.levelsGained or 0)
        skillData.newLevel = incomingData.newLevel or skillData.newLevel
    elseif incomingData.type == 'levelDown' then
        skillData.levelsLost = skillData.levelsLost + (incomingData.levelsLost or 0)
        skillData.newLevel = incomingData.newLevel or skillData.newLevel
    end

    if accumulator.timer then
        ClearTimeout(accumulator.timer)
    end

    local delay = AccumulationDelays[incomingData.type] or 2000
    accumulator.timer = SetTimeout(delay, function()
        Functions.FlushAccumulator(key)
    end)
end
--[[
    Immediate Notification
    
    Creates and displays a notification immediately without accumulation.
    Used for critical notifications that should not be delayed or combined.
    
    @param data table - Notification data
        - type: Notification type
        - skill: Skill name
        - Various other fields depending on type
--]]
function Functions.ImmediateNotification(data)
    if not data or not data.type then
        return
    end

    Functions.CreateAndQueueNotification(data)
end

--[[
    Process Multi-Skill Notification Data

    Handles consolidated notification data from server that may contain multiple skills.
    Processes each skill individually through the accumulation system.

    @param data table - Consolidated notification data from server
        - type: Notification type
        - skills: Table of skill data (skill_name -> skill_data)
--]]
function Functions.ProcessMultiSkillNotification(data)
    if not data.skills or type(data.skills) ~= 'table' then
        lib.print.info("Invalid multi-skill notification data:", json.encode(data))
        return
    end

    -- Process each skill individually through accumulation
    for skillName, skillData in pairs(data.skills) do
        Functions.AccumulateNotification(buildIndividualNotification(data.type, skillName, skillData))
    end
end

local FunctionModule = {
    Functions = Functions,
    NotificationManager = NotificationManager,
}
_G.SkillsNotificationInstance = FunctionModule
-- ============================================================================
-- CLEANUP AND RESOURCE MANAGEMENT
-- ============================================================================

--[[
    Resource Stop Cleanup Handler

    Cleans up all timers, accumulators, and queues when the resource stops
    to prevent memory leaks and orphaned timers.

    Event: 'onResourceStop'
    Triggered by: FiveM when resource stops
--]]
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Clear all accumulator timers to prevent orphaned timers
        for key, accumulator in pairs(NotificationManager.accumulator) do
            if accumulator.timer then
                ClearTimeout(accumulator.timer)
            end
        end
        
        -- Reset all manager state
        NotificationManager.accumulator = {}
        NotificationManager.queue = {}
        NotificationManager.isProcessing = false
        
        lib.print.info("Skills notification system cleaned up successfully")
    end
end)

return {
    Functions = Functions,
}

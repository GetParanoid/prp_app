local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local Hooks = require('server.sv_hooks')
local Tracking = require('server.sv_xpTracking')
local microtime = os.microtime

-- Fetch Functions
local function FetchPlayerSkills(src)
    local xPlayer = exports.qbx_core:GetPlayer(src)
    return xPlayer and xPlayer.PlayerData.metadata['PLAYER_SKILLS'] or {}
end
exports('FetchPlayerSkills', FetchPlayerSkills)

local function FetchPlayerSkillXP(src, skill)
    local skills = FetchPlayerSkills(src)
    return skills[skill] or ServerConfig.XPSettings.BASE_LEVEL_XP
end
exports('FetchPlayerSkillXP', FetchPlayerSkillXP)

local function FetchPlayerSkillLevel(src, skill)
    return SharedFunctions.XPToLevel(FetchPlayerSkillXP(src, skill))
end
exports('FetchPlayerSkillLevel', FetchPlayerSkillLevel)

local function GetPlayerCategoryTotalXP(src, category)
    if not src or not category then return 0 end
    
    local xPlayer = exports.qbx_core:GetPlayer(src)
    if not xPlayer then return 0 end
    
    local playerSkills = xPlayer.PlayerData.metadata['PLAYER_SKILLS']
    if not playerSkills then return 0 end
    
    -- Validate category exists
    if not SharedConfig.Categories[category] then return 0 end
    
    local totalXP = 0
    
    -- Iterate through all skills and sum XP for matching category
    for skillName, skillConfig in pairs(SharedConfig.Skills) do
        if skillConfig.category == category then
            local skillXP = playerSkills[skillName] or ServerConfig.XPSettings.BASE_LEVEL_XP
            totalXP = totalXP + skillXP
        end
    end
    return totalXP
end

exports('GetPlayerCategoryTotalXP', GetPlayerCategoryTotalXP)

local function InitPlayerMetadata(source)
    local start = microtime()
    if not Player(source).state.isLoggedIn then return end
    local xPlayer = exports.qbx_core:GetPlayer(source)
    if not xPlayer then return end

    local playerSkills = xPlayer.PlayerData.metadata['PLAYER_SKILLS'] or {}
    local baseXP = ServerConfig.XPSettings.BASE_LEVEL_XP

    -- Validate and update player skills
    for skill, _ in pairs(SharedConfig.Skills) do
        local skillXP = playerSkills[skill] or baseXP
        local maxXP = SharedFunctions.GetMaxXPForSkill(skill)
        if skillXP < baseXP then
            lib.print.info(('Skill %s below BASE_LEVEL_XP. Resetting. ID: %d'):format(skill, source))
            skillXP = baseXP
        elseif skillXP > maxXP then
            lib.print.info(('Skill %s exceeds MAX_XP. Resetting. ID: %d'):format(skill, source))
            skillXP = maxXP
        end
        playerSkills[skill] = skillXP
    end

    -- Remove invalid skills
    if ServerConfig.RemoveSkillsNotInConfig then
        for skill in pairs(playerSkills) do
            if not SharedConfig.Skills[skill] then
                lib.print.info(('Skill [%s] not in config. Removing. ID: %d'):format(skill, source))
                playerSkills[skill] = nil
            end
        end
    end
    -- Apply changes
    xPlayer.Functions.SetMetaData('PLAYER_SKILLS', playerSkills)
    --TODO: Swap to Loki log.
    lib.print.info(('[%.2fms] InitPlayerMetadata - Success | USER: %s[ID: %d]'):format(microtime() - start, GetPlayerName(source), source))
    return true
end

exports('InitPlayerMetadata', InitPlayerMetadata)

--! Add Function
--[[
    Adds XP to a player's skill(s), applying scaling based on the current level.
    @param src: player source ID.
    @param skillData: table of skills with XP values and possible split amount.
        @param xpSource: string, source/activity for XP.
        @param skills: table of skills names(key) and xp values
        @param splitAmount (optional) amount to split XP between skills. If not provided, XP is added to skills with their corresponding key/value pairs.+

            --? Examples:
                Adding different XP values to multiple skills
                        Table format: skillData = { xpSource = "boosting", skills = { skill1 = 500, skill2 = 250 } }
                            In this case, 500 XP will be added to skill1 and 250 XP will be added to skill2.
                Adding XP to a single skill
                        Table format: skillData = { xpSource = "boosting", skills = { skill1 = 1000 } }
                            In this case, 1000 XP will be added to skill1.
            OR
                Splitting XP equally between multiple skills
                        Table format: skillData = { xpSource = "boosting", skills = { skill1, skill2 }, splitAmount = 1000 }
                            In this case, 1000 XP will be split equally between skill1 and skill2 (500 XP each).
    @return true/false, success/reason
]]--
local function AddPlayerSkillXP(src, skillData)
    -- Validation and early returns
    if not src then return false, "Invalid source" end
    
    local player = Player(src)
    if not player.state.isLoggedIn then return false, "Player not logged in" end

    local xPlayer = exports.qbx_core:GetPlayer(src)
    if not xPlayer then return false, "xPlayer fetch failed" end

    local playerSkills = xPlayer.PlayerData.metadata['PLAYER_SKILLS']
    if not playerSkills then return false, "PLAYER_SKILLS missing" end

    local skills = skillData.skills
    if not skills then return false, "Invalid skillData format" end

    -- Pre-process split amount if needed
    if skillData.splitAmount then
        local splitValue = skillData.splitAmount / #skills
        local newSkills = {}
        for _, skill in ipairs(skills) do
            newSkills[skill] = splitValue
        end
        skills = newSkills
    end

    -- Single hook validation call
    local hookValidation = Hooks.Functions.ValidateXPModification({
        source = src,
        skills = skills,
        type = 'gain',
        skillData = skillData
    })

    if not hookValidation.validationPassed then
        return false, hookValidation.reason
    end

    -- Pre allocate and cache frequently used values
    local xpGainPayload = { source = src, type = 'xpGain', skills = {} }
    local levelUpPayload = { source = src, type = 'levelUp', skills = {} }
    local baseXP = ServerConfig.XPSettings.BASE_LEVEL_XP
    local xpSource = skillData.xpSource
    local splitAmount = skillData.splitAmount or 'false'
    local hasXpGains = false
    local hasLevelUps = false

    --? Main processing loop
    for skill, rawGain in pairs(skills) do
        -- Validation
        if SharedConfig.Skills[skill] and rawGain > 0 then
            local currentXP = playerSkills[skill] or baseXP
            local level = SharedFunctions.XPToLevel(currentXP)
            local scaledXP = ServerConfig.Functions.CalcScaledXPGain(rawGain, level)
            local newXP = math.min(currentXP + scaledXP, SharedFunctions.GetMaxXPForSkill(skill))

            Tracking.TrackXPChange({
                source = src,
                skill = skill,
                amount = rawGain,
                scaled = scaledXP,
                xpSource = xpSource,
                split = splitAmount,
                level = level,
                actionType = 'xpGain'
            })

            -- Level up check for hooks
            local newLevel = SharedFunctions.XPToLevel(newXP)
            if newLevel > level then
                levelUpPayload.skills[skill] = {
                    skill = skill,
                    oldLevel = level,
                    newLevel = newLevel,
                    levelsGained = newLevel - level
                }
                hasLevelUps = true
            end

            xpGainPayload.skills[skill] = scaledXP
            playerSkills[skill] = newXP
            hasXpGains = true
        end
    end

    -- Metadata update
    xPlayer.Functions.SetMetaData('PLAYER_SKILLS', playerSkills)

    -- Hook triggers
    if hasXpGains then Hooks.Functions.TriggerHook('xpGain', xpGainPayload) end
    if hasLevelUps then Hooks.Functions.TriggerHook('levelUp', levelUpPayload) end

    return true, 'Success'
end


exports('AddPlayerSkillXP', AddPlayerSkillXP)

--! Remove Function
--[[
    Removes XP to a player's skill(s), applying scaling based on the current level.
    @param src: player source ID.
    @param skillData: table of skills with XP values and possible split amount.
        @param xpSource: string, source/activity for XP.
        @param skills: table of skills names(key) and xp values
        @param splitAmount (optional) amount to split XP between skills. If not provided, XP is removed to skills with their corresponding key/value pairs.

            --? Examples:
                Removing different XP values to multiple skills
                        Table format: skillData = { xpSource = "boosting", skills = { skill1 = 500, skill2 = 250 } }
                            In this case, 500 XP will be removed to skill1 and 250 XP will be removed to skill2.
                Removing XP to a single skill
                        Table format: skillData = { xpSource = "boosting", skills = { skill1 = 1000 } }
                            In this case, 1000 XP will be removed to skill1.
            OR
                Splitting XP equally between multiple skills
                        Table format: skillData = { xpSource = "boosting", skills = { skill1, skill2 }, splitAmount = 1000 }
                            In this case, 1000 XP will be split equally between skill1 and skill2 (500 XP each).
    @return true/false, success/reason
]]--
local function RemovePlayerSkillXP(src, skillData)
    -- Validation and early returns
    if not src then return false, "Invalid source" end

    local player = Player(src)
    if not player.state.isLoggedIn then return false, "Player not logged in" end

    local xPlayer = exports.qbx_core:GetPlayer(src)
    if not xPlayer then return false, "xPlayer fetch failed" end

    local playerSkills = xPlayer.PlayerData.metadata['PLAYER_SKILLS']
    if not playerSkills then return false, "PLAYER_SKILLS missing" end

    local skills = skillData.skills
    if not skills then return false, "Invalid skillData format" end

    -- process split amount if needed
    if skillData.splitAmount then
        local splitValue = skillData.splitAmount / #skills
        local newSkills = {}
        for _, skill in ipairs(skills) do
            newSkills[skill] = splitValue
        end
        skills = newSkills
    end

    -- Hook validation
    local hookValidation = Hooks.Functions.ValidateXPModification({
        source = src,
        skills = skills,
        type = 'loss',
        skillData = skillData
    })

    if not hookValidation.validationPassed then
        return false, hookValidation.reason
    end

    -- Allocate and cache frequently used values
    local xpLossPayload = { source = src, type = 'xpLoss', skills = {} }
    local levelDownPayload = { source = src, type = 'levelDown', skills = {} }
    local baseXP = ServerConfig.XPSettings.BASE_LEVEL_XP
    local xpSource = skillData.xpSource
    local splitAmount = skillData.splitAmount or 'false'
    local hasXpLoss = false
    local hasLevelDowns = false

    --? Main processing loop
    for skill, xpLoss in pairs(skills) do
        -- Validation
        if SharedConfig.Skills[skill] and xpLoss > 0 then
            local currentXP = playerSkills[skill] or baseXP
            local level = SharedFunctions.XPToLevel(currentXP)
            local scaledXP = ServerConfig.Functions.CalcScaledXPGain(xpLoss, level)
            local newXP = math.max(currentXP - scaledXP, baseXP)

            Tracking.TrackXPChange({
                source = src,
                skill = skill,
                amount = xpLoss,
                scaled = scaledXP,
                xpSource = xpSource,
                split = splitAmount,
                level = level,
                actionType = 'xpLoss'
            })

            -- Level down check
            local newLevel = SharedFunctions.XPToLevel(newXP)
            local levelsLost = level - newLevel
            if levelsLost > 0 then
                levelDownPayload.skills[skill] = {
                    skill = skill,
                    oldLevel = level,
                    newLevel = newLevel,
                    levelsLost = levelsLost
                }
                hasLevelDowns = true
            end

            xpLossPayload.skills[skill] = scaledXP
            playerSkills[skill] = newXP
            hasXpLoss = true
        end
    end

    -- Metadata update
    xPlayer.Functions.SetMetaData('PLAYER_SKILLS', playerSkills)

    -- Hook triggers
    if hasXpLoss then Hooks.Functions.TriggerHook('xpLoss', xpLossPayload) end
    if hasLevelDowns then Hooks.Functions.TriggerHook('levelDown', levelDownPayload) end

    return true, 'Success'
end

exports('RemovePlayerSkillXP', RemovePlayerSkillXP)

--! Set Functions
local function SetPlayerSkillXP(src, skill, xp)
    local xPlayer = exports.qbx_core:GetPlayer(src)
    if not xPlayer or not SharedConfig.Skills[skill] then return end

    xp = math.max(ServerConfig.XPSettings.BASE_LEVEL_XP, math.min(xp, SharedFunctions.GetMaxXPForSkill(skill)))

    local playerSkills = FetchPlayerSkills(src)
    playerSkills[skill] = xp

    xPlayer.Functions.SetMetaData('PLAYER_SKILLS', playerSkills)
    return true
end

local function SetPlayerSkillLevel(src, skill, level)
    if not src or not SharedConfig.Skills[skill] then return end
    lib.print.info(('Attempt to set skill($s) level to %s for Player %s'):format(skill, level, src))
    local xp = ServerConfig.XP_TABLE[level] or ServerConfig.XPSettings.BASE_LEVEL_XP
    SetPlayerSkillXP(src, skill, xp)
    return true
end

local function ResetPlayerSkill(src, skill)
    if not src or not SharedConfig.Skills[skill] then return end
    SetPlayerSkillXP(src, skill, ServerConfig.XPSettings.BASE_LEVEL_XP)
    return true
end

local function ResetAllPlayerSkills(src)
    local xPlayer = exports.qbx_core:GetPlayer(src)
    if not xPlayer then return end
    xPlayer.Functions.SetMetaData('PLAYER_SKILLS', nil)
    return InitPlayerMetadata(src)
end
exports('ResetAllPlayerSkills', ResetAllPlayerSkills)


--! Debug / Test Functions
local DebugFunctions = {}
function DebugFunctions.ListAllSkills()
    local skillsString = ''
    for skill, _ in pairs(SharedConfig.Skills) do
        skillsString = skillsString .. skill .. ', '
    end
    lib.print.info(skillsString)
end

function DebugFunctions.PrintXPDifferences()
    lib.print.info('PrintXPDifferences')
    lib.print.info("Level\tXP Required\tDifference from Previous")
    lib.print.info("-----\t----------\t------------------------")
    for level = 1, ServerConfig.XPSettings.MAX_LEVEL do
        local difference = level > 1 and (ServerConfig.XP_TABLE[level] - ServerConfig.XP_TABLE[level-1]) or "N/A"
        lib.print.info(level .. "\t\t" .. ServerConfig.XP_TABLE[level] .. "\t\t" .. difference)
    end
end

function DebugFunctions.CalculateTimeToLevel()
    local drops = {1, 10, 20, 50, 100, 200, 500}
    local xpDropTimer = 60 -- XP Drops every 60 seconds

    lib.print.info('CalculateTimeToLevel')
    lib.print.info(xpDropTimer, 'second XP drops')
    lib.print.info("Drop Amount     | Time to Max Level | Total Drops | Effective XP per | 1-20 Scaling (%)")

    for _, xpPerDrop in ipairs(drops) do
        local level = 1
        local totalXPReceived = 0
        local totalDrops = 0
        local timeRequiredSeconds = 0
        local xpGained = 0

        while level < ServerConfig.XPSettings.MAX_LEVEL do
            local scaledXP = ServerConfig.Functions.CalcScaledXPGain(xpPerDrop, level)
            totalXPReceived = totalXPReceived + scaledXP
            totalDrops = totalDrops + 1
            timeRequiredSeconds = timeRequiredSeconds + xpDropTimer
            xpGained = xpGained + scaledXP

            -- Level up when enough XP is accumulated
            local xpToNextLevel = ServerConfig.XP_TABLE[level + 1] - ServerConfig.XP_TABLE[level]
            while xpGained >= xpToNextLevel and level < ServerConfig.XPSettings.MAX_LEVEL do
                xpGained = xpGained - xpToNextLevel
                level = level + 1
                if level < ServerConfig.XPSettings.MAX_LEVEL then
                    xpToNextLevel = ServerConfig.XP_TABLE[level + 1] - ServerConfig.XP_TABLE[level]
                end
            end
        end

        local timeToLevelMinutes = timeRequiredSeconds / 60
        local effectiveXPPerDrop = totalXPReceived / totalDrops
        local scalingReduction = ((xpPerDrop - effectiveXPPerDrop) / xpPerDrop) * 100

        lib.print.info(string.format(
            "%d XP per drop   | %.2f minutes   | %d drops   | %.1f XP   | %.1f%% reduction",
            xpPerDrop, timeToLevelMinutes, totalDrops, effectiveXPPerDrop, scalingReduction
        ))
    end
end

function DebugFunctions.BenchmarkXPCalculation()
    local iterations = 1000000
    local startTime = os.clock()

    for i = 1, iterations do
        local level = 10
        local xpGain = 1000
        ServerConfig.Functions.CalcScaledXPGain(xpGain, level)
    end

    local elapsedTime = os.clock() - startTime
    lib.print.info(string.format("XP Calculation Benchmark: %d iterations took %.4f seconds", iterations, elapsedTime))
end

function DebugFunctions.BenchmarkXPModification(source)
    
    local iterations = 1000

    lib.print.info(("Benchmarking AddPlayerSkillXP() for %d iterations..."):format(iterations))
    collectgarbage("collect")  -- Force full GC before starting the benchmark

    local testSkillData = {
        xpSource = 'benchmark',
        skills = {
            ['Hacking'] = 100,
            ['Strength'] = 50,
        }
    }
    local startTime = os.clock()
    for i = 1, iterations do
        local result, msg = AddPlayerSkillXP(source, testSkillData)
    end


    local endTime = os.clock()
    local totalTime = endTime - startTime
    local avgTime = totalTime / iterations

    lib.print.info(("Total Time: %.6f seconds"):format(totalTime))
    lib.print.info(("Average Time per Call: %.6f seconds"):format(avgTime))
end

function DebugFunctions.CalculateScaledXPReduction(xpGain)
    lib.print.info('CalculateScaledXPReduction')
    lib.print.info(string.format("Level\tXP Reduction\tScaled XP (xpGain: %d)", xpGain))

    for level = 1, #ServerConfig.XP_TABLE do
        local scaledXP = ServerConfig.Functions.CalcScaledXPGain(xpGain, level)

        -- Calculate reduction as the actual percentage drop from original XP gain
        local reduction = 100 * (1 - (scaledXP / xpGain))

        lib.print.info(string.format(
            "%d\t\t~%.1f%%\t\t%d XP ",
            level, reduction, scaledXP
        ))
    end
end





return {
    AddPlayerSkillXP = AddPlayerSkillXP,
    FetchPlayerSkillXP = FetchPlayerSkillXP,
    FetchPlayerSkillLevel = FetchPlayerSkillLevel,
    InitPlayerMetadata = InitPlayerMetadata,
    SetPlayerSkillXP = SetPlayerSkillXP,
    SetPlayerSkillLevel = SetPlayerSkillLevel,
    ResetPlayerSkill = ResetPlayerSkill,
    ResetAllPlayerSkills = ResetAllPlayerSkills,
    GetPlayerCategoryTotalXP = GetPlayerCategoryTotalXP,
    DebugFunctions = DebugFunctions,
}

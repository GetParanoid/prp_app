
-- local Config = require('config.server')
local SharedConfig = require('config.shared')

local function GetXPTable()
    return GlobalState.XP_TABLE
end

local function XPToLevel(xp)
    local xpTable = GetXPTable()
    for level, requiredXP in ipairs(xpTable) do
        if xp < requiredXP then
            return level - 1
        end
    end
    return 20 --TODO: MAX_LEVEL
end

local function GetSkillRank(skill, xp)
    local level = XPToLevel(xp)
    if SharedConfig.Skills[skill] and SharedConfig.Skills[skill].levels[level] then
        return SharedConfig.Skills[skill].levels[level].name
    end
    return 'Unknown'
end

local function GetMaxXPForSkill(skill)
    return GlobalState.XP_TABLE[SharedConfig.Skills[skill].maxLevel] or Config.BASE_LEVEL_XP
end

return {
    GetXPTable = GetXPTable,
    XPToLevel = XPToLevel,
    GetSkillRank = GetSkillRank,
    GetMaxXPForSkill = GetMaxXPForSkill
}

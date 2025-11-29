local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ClientFunctions = require('client.cl_functions')
-- Open Skills Menu
local function OpenSkillsMenu()
    local categories = {}
    local PLAYER_SKILLS = QBX.PlayerData.metadata['PLAYER_SKILLS']

    for catKey, catData in pairs(SharedConfig.Categories) do
        if catData.hidden then
            local hasSkill = false
            for skill, xp in pairs(PLAYER_SKILLS) do
                if SharedConfig.Skills[skill] and SharedConfig.Skills[skill].category == catKey and xp > 100 then
                    hasSkill = true
                    break
                end
            end
            if not hasSkill then goto continue end
        end

        table.insert(categories, { key = catKey, name = catData.name, icon = catData.icon, description = catData.description })

        ::continue::
    end

    -- Cheeky little table.sort to sort the categories alphabetically
    table.sort(categories, function(a, b)
        return a.name < b.name
    end)
    -- Create ox_lib context options
    local options = {}
    for _, category in ipairs(categories) do
        table.insert(options, {
            title = category.name,
            icon = category.icon,
            description = category.description,
            event = '_skills:cl:openCategoryMenu',
            args = category.key
        })
    end

    lib.registerContext({
        id = 'skills_menu',
        title = 'Skills Menu',
        menu = 'main_menu',
        options = options
    })

    lib.showContext('skills_menu')
end
exports('OpenSkillsMenu', OpenSkillsMenu)

-- NetEvent to open a specific category menu, i.e "Drugs", "Personal Skills", "Gathering", etc.
--  TODO: This should probably be turned into a function and then exported so we can use the function internally instead of using a NetEvent
RegisterNetEvent('_skills:cl:openCategoryMenu', function(categoryKey)
    local PLAYER_SKILLS = QBX.PlayerData.metadata['PLAYER_SKILLS']
    local category = SharedConfig.Categories[categoryKey]
    if not category then return end

    local skills = {}

    for skillKey, skillData in pairs(SharedConfig.Skills) do
        if skillData.category == categoryKey then
            -- If the skill is hidden and the player doesn't have enough XP to unlock it
            --      (BASE_XP + 1 i.e meaning they've earned at least 1xp in the skill),
            --          skip it and don't show it in the menu.
            -- TODO: Change '100' to BASE_XP
            if skillData.hidden and (not PLAYER_SKILLS[skillKey] or PLAYER_SKILLS[skillKey] <= 100) then
                goto continue
            end

            local level = SharedFunctions.XPToLevel(PLAYER_SKILLS[skillKey] or BASE_LEVEL_XP or 100)
            local levelName = SharedFunctions.GetSkillRank(skillKey, PLAYER_SKILLS[skillKey] or BASE_LEVEL_XP or 100)

        table.insert(skills, {
            key = skillKey,
            title = ('%s - %s'):format(skillKey, levelName),
            name = skillData.name,
            icon = skillData.icon,
            description = ('( Level: %d - Current XP: %d ) Next Level: %d XP'):format(level, PLAYER_SKILLS[skillKey], GlobalState.XP_TABLE[level + 1] or GlobalState.XP_TABLE[level]),
            progress = ClientFunctions.LevelPercentage(PLAYER_SKILLS[skillKey]),
            colorScheme = ClientFunctions.ProgressionColor(PLAYER_SKILLS[skillKey]),
        })
    end
        ::continue::
    end

    -- Sort skills alphabetically by name
    table.sort(skills, function(a, b)
        return a.name < b.name
    end)
    -- Create menu options
    local options = {}
    for _, skill in ipairs(skills) do
        table.insert(options, {
            title = skill.title,
            icon = skill.icon,
            description = skill.description,
            progress = skill.progress,
            colorScheme = skill.colorScheme,
            -- event = '_skills:cl:openSkillDetails', -- TODO: Add Skill Details Menu / Progression area
            args = skill.key
        })
    end

    lib.registerContext({
        id = 'category_menu_' .. categoryKey,
        title = category.name,
        menu = 'skills_menu',
        options = options
    })

    lib.showContext('category_menu_' .. categoryKey)
end)

-- Open Skill Details Menu
RegisterNetEvent('_skills:cl:openSkillDetails', function(skillKey)
    lib.print.info(skillKey)
    local skill = SharedConfig.Skills[skillKey]
    if not skill then return end
    local PLAYER_SKILLS = QBX.PlayerData.metadata['PLAYER_SKILLS']
    local xp = PLAYER_SKILLS[skillKey] or BASE_LEVEL_XP
    local level = SharedFunctions.XPToLevel(xp)
    local levelName = SharedFunctions.GetSkillRank(skillKey, xp)

    lib.registerContext({
        id = 'skill_details_' .. skillKey,
        title = skill.name,
        menu = 'category_menu_' .. skill.category,
        description = ('Level: %d (%s)\nXP: %d'):format(level, levelName, xp),
        options = {
            {
                title = 'Progression',
                description = ('Level: %d (%s)'):format(level, levelName),
                icon = SharedConfig.Skills[skillKey].icon,
                progress = ClientFunctions.LevelPercentage(PLAYER_SKILLS[skillKey]),
                colorScheme = ClientFunctions.ProgressionColor(PLAYER_SKILLS[skillKey]),
            },
        },
    })

    lib.showContext('skill_details_' .. skillKey)
end)


return {
    OpenSkillsMenu = OpenSkillsMenu,
}
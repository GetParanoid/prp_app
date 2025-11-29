local SharedConfig = require('config.shared')

if true then return end --! Return early so these hooks aren't registered
Wait(500) --! Not needed but used here for testing to add delay as if it's a separate script.


local hookExport = exports['hof-skills']


local validateXPModification = hookExport:registerHook('xpModification', function(payload)
--? Triggers:
--?   on: export AddPlayerSkillXP() & RemovePlayerSkillXP() before a player's XP is modified
--?        payload:
--?              source: source of the event (The player who's XP is being modified)
--?              type: type of the event (xpGain, xpLoss)
--?              skills: table of skills and their xp gains/losses
--?              skillData: Table of the player's current (pre-Modification) skills
-- ? expected Return:
-- ?        @param1: boolean - true if the xp modification should be allowed, false if it should be blocked
-- ?        @param2: string - reason for blocking the xp modification
    -- lib.print.info("XP Modification!", json.encode(payload))
    if payload.skillData.amountToSplit and payload.skillData.amountToSplit > 1000000 then
        --! If any xpModification hook returns false, xp gain will be blocked.
        return false, "You can't split XP that high!"
    end
    if payload.skills["strength"] and payload.skills["strength"] > 200000 then
        --! If any xpModification hook returns false, xp gain will be blocked.
        return false, "XP gain for Strength is too high!"
    end
    --! If all xpModification hooks return true, the xp gain will be allowed.
    return true, "test"
end)


local xpGain = hookExport:registerHook('xpGain', function(payload)
--? Triggers:
--?   on: export AddPlayerSkillXP when a player gains XP, runs after xpModification hook validates.
--?        payload:
--?              source: source of the event (The player who's XP was modified)
--?              type: type of the event (xpGain, xpLoss)
--?              skills: table of skills and their xp gains
    -- lib.print.info("XP Gained!", json.encode(payload))
    -- for skill, xpGain in pairs(payload.skills) do
    --     lib.print.info(skill, xpGain)
    -- end
end)

local xpLoss = hookExport:registerHook('xpLoss', function(payload)
--? Triggers:
--?   on: export RemovePlayerSkillXP when a player losses XP, runs after xpModification hook validates.
--?        payload:
--?              source: source of the event (The player who's XP was modified)
--?              type: type of the event (xpGain, xpLoss)
--?              skills: table of skills and their xp losses
    -- lib.print.info("XP Lost!", json.encode(payload))
        -- for skill, xpLoss in pairs(payload.skills) do
    --     lib.print.info(skill, xpLoss)
    -- end
end)

local levelUp = hookExport:registerHook('levelUp', function(payload)
--? Triggers:
--?   on: export AddPlayerSkillXP when a level up is detected, runs after xpModification hook validates.
--?        payload:
--?              source: source of the event (The player who's XP was modified)
--?              type: type of the event (levelUp, leveLDown)
--?              skills: table of skills and their level gains
--?                     skill: skill name
--?                     oldLevel: Skill's old level
--?                     newLevel: Skill's new level
--?                     levelsGained: Amount of levels gained
    -- lib.print.info("Level gained!", json.encode(payload))
    for skill, levelUp in pairs(payload.skills) do
        -- lib.print.info(skill, levelUp.oldLevel, levelUp.newLevel, levelUp.levelsGained)
    end
end)

local levelDown = hookExport:registerHook('levelDown', function(payload)
    -- lib.print.info("Level Lost!", json.encode(payload))
    for skill, levelDown in pairs(payload.skills) do
        -- lib.print.info(skill, levelUp.oldLevel, levelUp.newLevel, levelUp.levelsLost)
    end
end)

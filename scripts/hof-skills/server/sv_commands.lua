local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local ServerFunctions = require('server.sv_functions')
local Logging = require('server.sv_logging')

local function Notify(source, type, title, description)
    exports['hof-base']:notify(source, {
        title = string.format('[STAFF] %s', title),
        description = description,
        position = 'top-right',
        type = type,
        icon = 'fa-shield-halved',
        duration = 7500,
    })
end

--! Command to open the skills menu
lib.addCommand('skills', {
    help = '[Skills] Open Skills Menu',
    params = {}
    }, function(source, args)
        TriggerClientEvent('_skills:cl:OpenSkillsMenu', source)
end)


--! Staff Commands
lib.addCommand('staff:skills:reinitialize', {
    help = '[Staff/Skills] Reinitialize Player Skills, useful if players have a bugged skills. This is also triggered on server join',
    restricted = 'group.admin',
    params = {{ name = 'id', type = 'number', help = 'Player ID' }}
    }, function(source, args)
        if not Player(args.id).state.isLoggedIn then Notify(source, 'error', string.format('%s(ID: %s) is not logged in', GetPlayerName(args.id), args.id)) return end
        if ServerFunctions.InitPlayerMetadata(args.id) then
            Notify(source, 'success', string.format('Reinitialized skills  for %s (ID: %s)', GetPlayerName(args.id), args.id))
            Notify(args.id, 'success', 'Your skills have been reinitialized')
        else
            Notify(source, 'error', 'Failed to reinitialize player skills')
        end
end)

lib.addCommand('staff:skills:toggleScaling', {
    help = '[Staff/Skills] Toggles XP Scaling on/off dynamically. Does not save over script restarts.',
    restricted = 'group.admin',
    }, function(source, args)
        local success, status = ServerConfig.Functions.ToggleXPScaling()
        if success then
            Notify(source, 'success', string.format('XP Scaling Status: %s', status))
        else
            Notify(source, 'error', 'Failed to toggle XP Scaling')
        end
end)

lib.addCommand('staff:skills:setlevel', {
        help = '[Staff/Skills] Set skill level for a specific skill',
        restricted = 'group.admin',
        params = {{ name = 'id', type = 'number', help = 'Player ID' },{ name = 'skill', type = 'string', help = 'Skill name' },{ name = 'level', type = 'number', help = 'Level' }}
    },function(source, args)
        local skill, level =  args.skill, args.level
        if not Player(args.id).state.isLoggedIn then Notify(source, 'error', string.format('%s(ID: %s) is not logged in', GetPlayerName(args.id), args.id)) return end
        if not SharedConfig.Skills[skill] then Notify(source, 'error', string.format('Skill `%s` not found in config', skill)) return end

        if ServerFunctions.SetPlayerSkillLevel(args.id, skill, level) then
            Notify(source, 'success', string.format('%s level %s set for %s (ID: %s)', skill, level, GetPlayerName(args.id), args.id))
            Notify(args.id, 'success', string.format('Your skill level for %s has been set to %s', skill, level))
        else
            Notify(source, 'error', string.format('Failed to set %s level %s for %s (ID: %s)', skill, level, GetPlayerName(args.id), args.id))
        end
end)

lib.addCommand('staff:skills:setxp', {
        help = '[Staff/Skills] Sets XP for a specific skill',
        restricted = 'group.admin',
        params = {{ name = 'id', type = 'number', help = 'Player ID' },{ name = 'skill', type = 'string', help = 'Skill name' },{ name = 'xp', type = 'number', help = 'XP Amount' }}
    }, function(source, args)
        local skill, xp =  args.skill, args.xp
        if not SharedConfig.Skills[skill] then Notify(source, 'error', string.format('Skill `%s` not found in config', skill)) return end
        if not Player(args.id).state.isLoggedIn then Notify(source, 'error', string.format('%s(ID: %s) is not logged in', GetPlayerName(args.id), args.id)) return end
        if ServerFunctions.SetPlayerSkillXP(args.id, skill, xp) then
            Notify(source, 'success', string.format('%s XP set to %s for %s (ID: %s)', skill, xp, GetPlayerName(args.id), args.id))
            Notify(args.id, 'success', string.format('Your XP for %s has been set to %s', skill, xp))
        else
            Notify(source, 'error', string.format('Failed to set %s XP %s for %s (ID: %s)', skill, xp, GetPlayerName(args.id), args.id))
        end
end)

lib.addCommand('staff:skills:reset', {
        help = '[Staff/Skills] Reset XP for a specific skill',
        restricted = 'group.admin',
        params = {{ name = 'id', type = 'number', help = 'Player ID' },{ name = 'skill', type = 'string', help = 'Skill name' }}
    }, function(source, args)
        local  skill = args.skill
        if not SharedConfig.Skills[skill] then Notify(source, 'error', string.format('Skill `%s` not found in config', skill)) return end
        if not Player(args.id).state.isLoggedIn then Notify(source, 'error', string.format('%s(ID: %s) is not logged in', GetPlayerName(args.id), args.id)) return end
        if  ServerFunctions.ResetPlayerSkill(args.id, skill) then
            Notify(source, 'success', string.format('%s XP reset for %s (ID: %s)', skill, GetPlayerName(args.id), args.id))
            Notify(args.id, 'success', string.format('Your XP for %s has been reset', skill))
        else
            Notify(source, 'error', string.format('Failed to reset %s XP for %s (ID: %s)', skill, GetPlayerName(args.id), args.id))
        end
end)

lib.addCommand('staff:skills:reset:all', {
    help = '[Staff/Skills] Resets all skills for a player',
    restricted = 'group.admin',
    params = {{ name = 'id', type = 'number', help = 'Player ID to reset' }, { name = 'confirm', type = 'string', help = 'First Confirmation [yes/confirm/no]' }}
    }, function(source, args)
        local firstConfirmation = args.confirm
        if not args.id or not firstConfirmation then return end
        if firstConfirmation ~= 'yes' and firstConfirmation ~= 'confirm' then return end
        if ServerFunctions.ResetAllPlayerSkills(args.id) then
            Notify(source, 'success', string.format('All skills reset for %s (ID: %s)', GetPlayerName(args.id), args.id))
            Notify(args.id, 'success', string.format('Your skills have been reset'))
        else
            Notify(source, 'error', string.format('Failed to reset all skills for %s (ID: %s)', GetPlayerName(args.id), args.id))
        end
end)

--! Start Testing & Benchmarking Commands
lib.addCommand('dev:skills:hook', {
    help = '[Staff/Skills/Dev] Hook Testing',
    restricted = '',
    params = {}
    }, function(source, args)
        local sources = {
            'dev-testing-1',
            'dev-testing-2',
            'dev-testing-3',
            'dev-testing-4',
            'dev-testing-5',
        }
        -- Get all skill names into an array
        local skillNames = {}
        for skillName, _ in pairs(SharedConfig.Skills) do
            table.insert(skillNames, skillName)
        end
        for i = 1, 1000 do
            local skillData = {
                skills = {},
                xpSource = sources[math.random(1, #sources)]
            }
            -- Add 1-5 random skills
            for j = 1, math.random(1, 5) do
                local randomSkillIndex
                repeat
                    randomSkillIndex = math.random(1, #skillNames)
                    Wait(1)
                until skillData.skills[skillNames[randomSkillIndex]] == nil
                skillData.skills[skillNames[randomSkillIndex]] = math.random(1, 75)
            end
            local result, reason = exports['hof-skills']:AddPlayerSkillXP(source, skillData)
            if math.random(1,2) == 1 then
                exports['hof-skills']:AddPlayerSkillXP(source, skillData)
            else
                exports['hof-skills']:RemovePlayerSkillXP(source, skillData)
            end
            -- Wait(200)
        end
end)

lib.addCommand('dev:skills:benchmark:sim', {
    help = '[Staff/Skills]',
    restricted = 'group.admin',
    params = {}
    }, function(source, args)
        local playerCount = 220
        local randomDelay = math.random(0, 5000) -- Simulates players getting xp at different times
        for i = 1, playerCount do
            Citizen.CreateThread(function()
                Wait(randomDelay)
                local skillData = {
                    xpSource = 'benchmark',
                    skills = {
                        ['Hacking'] = 200,
                        ['Strength'] = 5,
                    }
                }

                -- Simulate async behavior
                ServerFunctions.AddPlayerSkillXP(source, skillData)

                print(("Simulated thread %s for source %s"):format(i, source))
            end)
        end
end)

lib.addCommand('dev:skills:testLog', {
    help = '[Staff/Skills] Test Loki Logging',
    restricted = 'group.admin',
    params = {}
    }, function(source, args)
        lib.print.info('dev:skills:testLog')
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return end
            local level = 20
            local username, cid, characterName = GetPlayerName(source), xPlayer.PlayerData.citizenid, xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
            local steamIdent = GetPlayerIdentifierByType(source, 'steam')
            local steamID = (steamIdent and steamIdent:gsub('steam:',"")) or 'STEAM-NOT-FOUND'
            local discordIdent = GetPlayerIdentifierByType(source, 'discord')
            local discordID = (discordIdent and discordIdent:gsub('discord:',"")) or 'DISCORD-NOT-FOUND'
        for skillName, _ in pairs(SharedConfig.Skills) do
            local xpGain = math.random(20, 200)
            local scaledXP = ServerConfig.Functions.CalcScaledXPGain(xpGain, ServerFunctions.FetchPlayerSkillLevel(source, skillName))
            local skill = skillName
            local xpSource = 'testing-'..skillName
            local logMessage = string.format('%s "%s" gained %dXP (Scaled: %dXP) in %s[LVL: %d] from: %s',
                                                characterName, username, xpGain, scaledXP, skill, level, xpSource)
            local logData = {
                logSource = cid,
                logEvent = 'skills:xpGain',
                logMessage = logMessage,
                logTags = {
                    source =  source,
                    citizenid = cid,
                    character_name = characterName,
                    username = username,
                    steam = steamID,
                    discord = discordID,
                    skillname = skill,
                    xpSource = xpSource,
                    xpGain = xpGain,
                    scaledXP = scaledXP,
                    level = level
                }
            }
            Logging.Functions.Loki.SubmitLog((logData))
        end
end)

lib.addCommand('dev:skills:benchmark:addplayerxp', {
    help = '[Staff/Skills]',
    restricted = 'group.admin',
    params = {}
    }, function(source, args)
        ServerFunctions.DebugFunctions.BenchmarkXPModification(source)
end)

lib.addCommand('dev:skills:testxpGain', {
    help = '[Staff/Skills]',
    restricted = 'group.admin',
    params = {}
    }, function(source, args)
        -- Get all skill names into an array
        local skillNames = {}
        for skillName, _ in pairs(SharedConfig.Skills) do
            table.insert(skillNames, skillName)
        end

        local i = 100
        for e = 1, i do
            local randomSkillIndex = math.random(1, #skillNames)
            local skillData = {
                skills = {},
                xpSource = 'Testing'
            }
            skillData.skills[skillNames[randomSkillIndex]] = math.random(1, 20)
            local result, reason = ServerFunctions.AddPlayerSkillXP(source, skillData)
            Wait(5000)
        end
end)
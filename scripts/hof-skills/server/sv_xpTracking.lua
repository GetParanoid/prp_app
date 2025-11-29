local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local Logging = require('server.sv_logging')

local microtime = os.microtime
local Tracking = {Database = {}}
local xpQueue = {}
local queueInterval = 30000


local function getIdentifier(source, idType, default)
    local ident = GetPlayerIdentifierByType(source, idType)
    return ident and ident:gsub(idType .. ":", "") or default
end


function Tracking.InitQueueTimer()
    CreateThread(function()
        while ServerConfig.Logging.Database.enabled do
            Wait(queueInterval)
            Tracking.ProcessXPQueue()
        end
    end)
end

Tracking.ForceProcessQueue = function()
    Tracking.ProcessXPQueue()
end
-- Function to queue XP changes
function Tracking.TrackXPChange(data)
    if not ServerConfig.Logging.Database.enabled and not ServerConfig.Logging.Loki.enabled then return end
    local start = microtime()
    if not data.source or not data.skill or not data.amount or not data.xpSource or not data.actionType then return end
    local player = exports.qbx_core:GetPlayer(data.source)
    if not player or not player.PlayerData then return end

    local citizenid = player.PlayerData.citizenid
    if not citizenid then return end

    -- Add XP change to the queue
    if ServerConfig.Logging.Database.enabled then
        if not xpQueue[citizenid] then
            xpQueue[citizenid] = {}
        end
        xpQueue[citizenid][#xpQueue[citizenid] + 1] = {
            skill = data.skill,
            action = data.actionType,
            xpGain = data.actionType == "xpGain" and data.amount or 0,
            xpLoss = data.actionType == "xpLoss" and data.amount or 0,
            scaled = data.scaled,
            xpSource = data.xpSource,
            split = data.split and 1 or 0,
            timestamp = os.time()
        }
    end
    if not ServerConfig.Logging.Loki.enabled then return end

    local username = GetPlayerName(data.source)
    local characterName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local steamID = getIdentifier(data.source, "steam", "STEAM-NOT-FOUND")
    local discordID = getIdentifier(data.source, "discord", "DISCORD-NOT-FOUND")

    local logMessage
    if data.actionType == "xpGain" then
        logMessage = string.format('%s "%s" gained %dXP (Scaled: %dXP) in %s [Level: %d] from: %s',
                                            characterName, username, data.amount, data.scaled, data.skill, data.level, data.xpSource)
    else
        logMessage = string.format('%s "%s" lost %dXP (Scaled: %dXP) in %s [Level: %d] from: %s',
                                            characterName, username, data.amount, data.scaled, data.skill, data.level, data.xpSource)
    end
    local logData = {
        logSource = citizenid,
        logEvent = 'skills:'..data.actionType,
        logMessage =  logMessage,
        logTags = {
            source =  data.source,
            citizenid = citizenid,
            character_name = characterName,
            username = username,
            steam = steamID,
            discord = discordID,
            skillname = data.skill,
            xpSource = data.xpSource,
            xpGain = data.xpGain,
            scaledXP = data.scaled,
            level = data.level
        }
    }
    Logging.Functions.Loki.SubmitLog(logData)
    local elapsed = microtime() - start
    -- lib.print.info((string.format('[%.4fms] TrackXPChange - Success | USER: %s[ID: %d].', elapsed , GetPlayerName(data.source), data.source)))
    if elapsed > 1000 then
        local logData = {
            logSource = citizenid,
            logEvent = 'skills:Benchmark',
            logMessage =  'TrackXPChange - Slow Query ('..elapsed..'ms)',
            logTags = {
                elapsed = elapsed
            }
        }
        Logging.Functions.Loki.SubmitLog(logData)
    end
end

function Tracking.ProcessXPQueue()
    if next(xpQueue) == nil then return end -- Exit if queue is empty
    local start = microtime()

    local transactionQueries = {}
    local queueLength = 0

    for citizenid, xpEntries in pairs(xpQueue) do
        queueLength = queueLength + #xpEntries
        -- Create individual log entries for each XP change
        for _, entry in ipairs(xpEntries) do
            -- Individual entry JSON for each row
            local entryJSON = json.encode(entry)
            -- Insert individual log entry
            table.insert(transactionQueries, {
                query = [[
                    INSERT INTO skills_logs (citizenid, xp_data, timestamp)
                    VALUES (?, ?, ?)
                ]],
                values = { citizenid, entryJSON, os.time() }
            })
            -- Update skill data and separate scaled values
            table.insert(transactionQueries, {
                query = [[
                    INSERT INTO skills_stats (skill, xp_data)
                    VALUES (?, ?)
                    ON DUPLICATE KEY UPDATE
                        xp_data = JSON_SET(
                            xp_data,
                            '$.xpGain', COALESCE(JSON_VALUE(xp_data, '$.xpGain'), 0) + ?,
                            '$.xpLoss', COALESCE(JSON_VALUE(xp_data, '$.xpLoss'), 0) + ?,
                            '$.xpGainScaled', COALESCE(JSON_VALUE(xp_data, '$.xpGainScaled'), 0) + ?,
                            '$.xpLossScaled', COALESCE(JSON_VALUE(xp_data, '$.xpLossScaled'), 0) + ?
                        )
                ]],
                values = {
                    entry.skill,
                    entryJSON,
                    entry.xpGain,
                    entry.xpLoss,
                    entry.action == "xpGain" and entry.scaled or 0,
                    entry.action == "xpLoss" and entry.scaled or 0
                }
            })

            -- Adds total XP tracking by source
            -- This stores xpGain and xpLoss in the same row by xpSource
            table.insert(transactionQueries, {
                query = [[
                    INSERT INTO skills_xpsource_stats (xpSource, xp_data)
                    VALUES (?, JSON_OBJECT('xpGain', ?, 'xpLoss', ?, 'xpGainScaled', ?, 'xpLossScaled', ?))
                    ON DUPLICATE KEY UPDATE
                        xp_data = JSON_SET(
                            xp_data,
                            '$.xpGain', COALESCE(JSON_VALUE(xp_data, '$.xpGain'), 0) + ?,
                            '$.xpLoss', COALESCE(JSON_VALUE(xp_data, '$.xpLoss'), 0) + ?,
                            '$.xpGainScaled', COALESCE(JSON_VALUE(xp_data, '$.xpGainScaled'), 0) + ?,
                            '$.xpLossScaled', COALESCE(JSON_VALUE(xp_data, '$.xpLossScaled'), 0) + ?
                        )
                ]],
                values = {
                    entry.xpSource,
                    entry.action == "xpGain" and entry.xpGain or 0,
                    entry.action == "xpLoss" and entry.xpLoss or 0,
                    entry.action == "xpGain" and entry.scaled or 0,
                    entry.action == "xpLoss" and entry.scaled or 0,
                    entry.action == "xpGain" and entry.xpGain or 0,
                    entry.action == "xpLoss" and entry.xpLoss or 0,
                    entry.action == "xpGain" and entry.scaled or 0,
                    entry.action == "xpLoss" and entry.scaled or 0
                }
            })
        end
    end
    -- Execute all queued queries in a single transaction
    MySQL.transaction(transactionQueries, function(success)
        if success then
            lib.print.warn(string.format('XP Queue Processed %i queries in %.4fms', queueLength, (microtime() - start) / 1e3))
            xpQueue = {} -- Clear queue after successful save
        else
            lib.print.error("XP Queue transaction failed!")
        end
    end)
end
--! Database Functions
Tracking.Database = {}
function Tracking.Database.CreateSkillLogTable()
    local sqlTable = {
        {
            query = [[
                CREATE TABLE IF NOT EXISTS skills_logs (
                    id          INT AUTO_INCREMENT PRIMARY KEY,
                    citizenid   VARCHAR(50) NOT NULL,
                    xp_data     JSON NOT NULL,
                    timestamp   INT NOT NULL,
                    INDEX idx_citizenid (citizenid),
                    INDEX idx_timestamp (timestamp)
                );
            ]],
            values = nil
        }
    }

    local dbPromise = promise.new()

    MySQL.transaction(sqlTable, function(success)
        if success then
            dbPromise:resolve(true)
        else
            lib.print.error("Error executing skills_logs query!")
            dbPromise:reject("Database transaction failed")
        end
    end)

    return dbPromise
end

function Tracking.Database.SetupSkillStatsTable()
    local dbPromise = promise.new()

    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS skills_stats (
            skill   VARCHAR(50) PRIMARY KEY,
            xp_data JSON NOT NULL
        );
    ]]

    local skills = SharedConfig.Skills
    if not next(skills) then
        lib.print.warn("No skills found in SharedConfig.Skills. Skipping default inserts.")
        return dbPromise:resolve(true)
    end

    local insertValues = {}
    for skill in pairs(skills) do
        insertValues[#insertValues + 1] = string.format("('%s', '{}')", skill)
    end

    local insertQuery = "INSERT IGNORE INTO skills_stats (skill, xp_data) VALUES " .. table.concat(insertValues, ", ")

    MySQL.transaction({
        { query = createTableQuery, values = nil },
        { query = insertQuery, values = nil }
    }, function(success)
        if success then
            dbPromise:resolve(true)
        else
            lib.print.error("Database setup failed for skills_stats")
            dbPromise:reject("Database transaction failed")
        end
    end)

    return dbPromise
end

function Tracking.Database.CreateSkillSourceStatsTable()
    local sqlTable = {
        {
            query = [[
                CREATE TABLE IF NOT EXISTS skills_xpsource_stats (
                    xpSource VARCHAR(50) NOT NULL,
                    xp_data JSON NOT NULL,
                    PRIMARY KEY (xpSource)
                );
            ]],
            values = nil
        }
    }

    local dbPromise = promise.new()

    MySQL.transaction(sqlTable, function(success)
        if success then
            dbPromise:resolve(true)
        else
            lib.print.error("Error executing skills_xpsource_stats query!")
            dbPromise:reject("Database transaction failed")
        end
    end)

    return dbPromise
end



return Tracking
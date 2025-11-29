local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local ServerFunctions = require('server.sv_functions')
local Logging = require('server.sv_logging')
local Tracking = require('server.sv_xpTracking')
local Citizen = Citizen
local microtime = os.microtime


-- Register the event to initialize player metadata
RegisterNetEvent('_skills:sv:InitPlayerMetadata', function()
    ServerFunctions.InitPlayerMetadata(source)
end)

-- On Resource Start
do
    while not CONFIG_INIT do Wait(250) end
    if SharedConfig.Settings.Debug then
        lib.print.info('--------------------Debug Prints-------------------------')
        ServerFunctions.DebugFunctions.ListAllSkills()
        ServerFunctions.DebugFunctions.PrintXPDifferences()
        ServerFunctions.DebugFunctions.CalculateScaledXPReduction(100)
        ServerFunctions.DebugFunctions.CalculateTimeToLevel()
        ServerFunctions.DebugFunctions.BenchmarkXPCalculation()
        lib.print.info('------------------------------------------------------')
    end

    local dbBenchmark, elapsedDbBench
    if not ServerConfig.Logging.Database.enabled then 
        lib.print.warn('Database Logging Disabled, Skipping Checks.') 
    else
        lib.print.warn('Database Logging Enabled, Starting Database Check')
        local startDbBench = microtime()
        local dbTables = {
            Tracking.Database.CreateSkillLogTable(),
            Tracking.Database.SetupSkillStatsTable(),
            Tracking.Database.CreateSkillSourceStatsTable()
        }
        for _, db in ipairs(dbTables) do
            if not Citizen.Await(db) then
                lib.print.error('Database Check Failed, check server logs.')
                return
            end
        end
        elapsedDbBench = (microtime() - startDbBench) / 1e3
        dbBenchmark = string.format('Database Check took %.4fms', elapsedDbBench)
        lib.print.warn(string.format('%s, Database is ready to use.', dbBenchmark))
    end
    -- DB Ready, start initing players and init the tracking queue timer
    Tracking.InitQueueTimer()

    lib.print.warn('Initiating online Players.')
    -- Init all online players on resource start
    local startInitBench = microtime()
    for _, src in pairs(GetPlayers()) do
        ServerFunctions.InitPlayerMetadata(src)
    end
    local elapsedInitBench = (microtime() - startInitBench) / 1e3
    local initBenchmark = string.format('Player Init took %.4fms', elapsedInitBench)
    lib.print.warn(string.format('Online players initiated. %s', initBenchmark))

    --? Logging
    if dbBenchmark and elapsedDbBench then
        Logging.Functions.Loki.SubmitLog({logSource = 'SERVER', logEvent = 'skills:InfoLog',
        logMessage = dbBenchmark,
        logTags = {
            source =  'SERVER',
            debug = SharedConfig.Settings.Debug,
            elapsed = string.format('%s', dbBenchmark),
            trigger = 'Script Start',
            benchType = 'database',
            logType = 'skills:Benchmark'
        }})
        Logging.Functions.Loki.SubmitLog({logSource = 'SERVER', logEvent = 'skills:InfoLog',
        logMessage = initBenchmark,
        logTags = {
            source =  'SERVER',
            debug = SharedConfig.Settings.Debug,
            elapsed = string.format('%s', elapsedInitBench),
            trigger = 'Script Start',
            benchType = 'InitPlayerMetadata',
            logType = 'skills:Benchmark'
        }})
    end
end

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    lib.print.info('Script is Stopping')
    Logging.Functions.Loki.SubmitLog({logSource = 'SERVER', logEvent = 'skills:InfoLog',
        logMessage = 'Script is Stopping',
        logTags = {
            source =  'SERVER',
            debug = SharedConfig.Settings.Debug,
            logType = 'info'
        }})
    GlobalState.XP_TABLE = nil
end)
-- Initialize configuration status
CONFIG_INIT = false
local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local ServerFunctions = require('server.sv_functions')
local Logging = require('server.sv_logging')
Wait(1)

lib.print.info('------------------- SKILLS STARTING -------------------')
while not ServerConfig.XP_TABLE do
    lib.print.info('Waiting for ServerConfig to init')
    Wait(100)
end


-- Store the XP Table globally
lib.print.info('XP_TABLE Generated, setting to global state')
repeat
    GlobalState.XP_TABLE = ServerConfig.XP_TABLE
    lib.print.info('Waiting for GlobalState.XP_TABLE')
    Wait(100)
until GlobalState.XP_TABLE
lib.print.info('XP_TABLE GlobalState set.')

QBX = exports.qbx_core

--! Mark configuration as initialized,
--!     this must be set to true as all other server side files depend on it.
CONFIG_INIT = true
lib.print.info('Server Initialized')

Logging.Functions.Loki.SubmitLog({logSource = 'SERVER', logEvent = 'skills:InfoLog',
    logMessage = 'Server Initialized',
    logTags = {
        source =  'SERVER',
        debug = SharedConfig.Settings.Debug,
        logType = 'info',
    }})
lib.print.info('------------------- SKILLS STARTED -------------------')
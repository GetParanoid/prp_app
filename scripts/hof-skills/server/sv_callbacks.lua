local SharedConfig = require('config.shared')
local SharedFunctions = require('shared.sh_functions')
local ServerConfig = require('config.server')
local ServerFunctions = require('server.sv_functions')
local Logging = require('server.sv_logging')

lib.callback.register('_skills:server:GetCategoryTotalXP', function(source)
    return ServerFunctions.GetPlayerCategoryTotalXP(source)
end)
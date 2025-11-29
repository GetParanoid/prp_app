---@diagnostic disable: undefined-global
fx_version 'cerulean'
games {'gta5'}
lua54 'yes'
author 'GetParanoid'
description ''
version '1.0.0'


shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    'config/shared.lua',
    "shared/*.lua"
}

-- client_script "@hof-errors/client/cl_main.lua"
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'config/client.lua',
    "client/*.lua",
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'config/server.lua',
    'server/*',
}


lua54 'yes'
use_experimental_fxv2_oal 'yes'
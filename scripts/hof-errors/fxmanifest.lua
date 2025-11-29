---@diagnostic disable: undefined-global
fx_version 'cerulean'
games {'gta5'}
lua54 'yes'
author 'GetParanoid'
description ''
version '1.0.0'


shared_scripts {
    'config/shared.lua',
	'@ox_lib/init.lua',
}

client_script {
    'config/client.lua',
    "client/*.lua",
}
server_script {
    "config/server.lua",
    "server/*.lua",
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
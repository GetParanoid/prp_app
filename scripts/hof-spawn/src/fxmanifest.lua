fx_version 'cerulean'
game 'gta5'

author 'Overxtended (Boilerplate) | GetParanoid'
description 'HOF Spawn Selector'
version '2.0.0'

dependencies {
    '/server:7290',
    '/onesync',
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'lua/client/*.lua'
}

server_scripts {
    'lua/server/*.lua'
}

ui_page 'web/index.html'

files {
    'web/**/*'
}

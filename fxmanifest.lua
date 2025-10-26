fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Flux'
github 'https://github.com/fluxcz'
description 'FX Paycheck | Flux Development'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'game/src/cl/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'game/src/sv/*.lua'
}

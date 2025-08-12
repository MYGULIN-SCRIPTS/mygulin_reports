fx_version 'cerulean'
game 'gta5'

author 'Mygulin_'
description 'Report systém'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'

--FOR ANY SUPPORT -- https://discord.gg/Hjjd6U658Z
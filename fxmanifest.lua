fx_version 'cerulean'
game 'gta5'

author 'codescripts'
description 'codescripts'
version '1.0.0'

lua54 'yes'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/ar.lua'

}

client_scripts {
    'client/client.lua',
    'client/minigame.lua'
}

ui_page 'web/RepairKit.html'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

files {
    'web/*.*'
}
dependencies {
    'qb-core',
    'ox_lib',
    
}

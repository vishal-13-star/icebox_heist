fx_version 'cerulean'
game 'gta5'

name 'icebox_heist'
author 'vishal'
description 'Ice Box Heist using boii_minigames, QBCore, qb-target, and qb/ox doorlock integration'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'boii_minigames',
    'qb-doorlock'
}

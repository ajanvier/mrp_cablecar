fx_version 'cerulean'
game 'gta5'

author "Aurel"
description "Cablecar Script made for Mouchoirs RP, inspired by Jimathy's script"
version "1.0.0"

lua54 'yes'

shared_script {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_target',
    'PolyZone'
}
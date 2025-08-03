fx_version 'cerulean'
game 'gta5'

author 'idonttouchgrass development'
description 'Client-side texture reload with ox_lib, freeze, cooldown, webhook'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'config.lua',
    'client.lua'
}

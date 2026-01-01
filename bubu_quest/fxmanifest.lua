fx_version 'cerulean'
game 'gta5'

author 'Bubu Scripts'
version '1.0.0'

shared_script 'configuration/config.lua'

client_script 'src/client.lua'
server_script 'src/server.lua'

dependencies {
    'es_extended',
    'ox_target'
}
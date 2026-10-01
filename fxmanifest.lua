fx_version 'cerulean'
game 'gta5'
author 'SzCode / SzCore'
version '1.4.0-rc1'
shared_script 'shared/config.lua'
client_script 'client/main.lua'
server_scripts {'@oxmysql/lib/MySQL.lua','server/main.lua'}
ui_page 'web/index.html'
files {'web/index.html','web/style.css','web/app.js'}
dependencies {'oxmysql','szcore','szcore_vehicles','szcore_vehiclekeys','szcore_ui'}

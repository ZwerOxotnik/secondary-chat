config = {}
config.player = {}
config.player.settings = require('secondary-chat/config/settings/player')
config.player.info = require('secondary-chat/config/info/player')

for table, child_table in pairs( config.player.settings ) do
  for name, _ in pairs( child_table ) do
    config.player.settings[table][name].access = config.player.settings or nil
  end
end

config.global = {}
config.global.settings = require('secondary-chat/config/settings/global')
config.global.info = require('secondary-chat/config/info/global')

function update_global_config()
  for _, player in pairs( game.players ) do
    destroy_chat_gui(player)    
    local settings = global.secondary_chat.players[player.index].settings
    for table, child_table in pairs( config.player.settings ) do
      settings[table] = settings[table] or {}
      for name, data in pairs( child_table ) do
        if settings[table][name].state == nil or type(data.state) ~= type(settings[table][name]) then
          settings[table][name] = data
        end
        if settings[table][name].access == nil then
          settings[table][name].access = data.access or true
        end
      end
    end

    local info = global.secondary_chat.players[player.index].info
    for table, child_table in pairs( config.global.info ) do
      info[table] = info[table] or {}
      for name, data in pairs( child_table ) do      
        if info[table][name] == nil or type(data) ~= type(info[table][name]) then
          info[table][name] = data
        end
      end
    end
    create_chat_gui(player)
  end

  local settings = global.secondary_chat.global.settings
  for table, child_table in pairs( config.global.settings ) do
    settings[table] = settings[table] or {}
    for name, data in pairs( child_table ) do      
      if settings[table][name] == nil or type(data) ~= type(settings[table][name]) then
        settings[table][name] = data
      end
    end
  end

  local info = global.secondary_chat.global.info
  for table, child_table in pairs( config.global.info ) do
    info[table] = info[table] or {}
    for name, data in pairs( child_table ) do      
      if info[table][name] == nil or type(data) ~= type(info[table][name]) then
        info[table][name] = data
      end
    end
  end
end

function update_global_config_player(target)
  global.secondary_chat.players[target.index] = {}
  global.secondary_chat.players[target.index].settings = config.player.settings
  global.secondary_chat.players[target.index].info = config.player.info
  global.secondary_chat.players[target.index].blacklist = {}
  for _, player in pairs( game.connected_players ) do
    local table_chat = player.gui.left.table_chat
    if table_chat and table_chat.style.visible then
      create_chat_gui(player)
      --sc_change_button_allied(player)
    end
  end
  if not global.secondary_chat.state_chat then return end
  create_chat_gui(target)
end

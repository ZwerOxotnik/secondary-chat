config = {}
config.player = {}
config.player.settings = require('secondary-chat/config/settings/player')
config.player.info = require('secondary-chat/config/info/player')

for table, child_table in pairs( config.player.settings ) do
  for name, _ in pairs( child_table ) do
    if type(config.player.settings[table][name]) == 'table' then
      config.player.settings[table][name].access = config.player.settings or true
    end
  end
end

config.global = {}
config.global.settings = require('secondary-chat/config/settings/global')
config.global.info = require('secondary-chat/config/info/global')

function update_global_config_player(player) 
  local settings = global.secondary_chat.players[player.index].settings
  if settings then
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
  else
    global.secondary_chat.players[player.index].settings = config.player.settings
  end

  local info = global.secondary_chat.players[player.index].info
  if info then
    for table, child_table in pairs( config.global.info ) do
      info[table] = info[table] or {}
      for name, data in pairs( child_table ) do      
        if info[table][name] == nil or type(data) ~= type(info[table][name]) then
          info[table][name] = data
        end
      end
    end
  else
    global.secondary_chat.players[player.index].info = config.global.info
  end
end

function update_global_config()
  local settings = global.secondary_chat.global.settings
  if settings then
    for table, child_table in pairs( config.global.settings ) do
      settings[table] = settings[table] or {}
      for name, data in pairs( child_table ) do      
        if settings[table][name] == nil or type(data) ~= type(settings[table][name]) then
          settings[table][name] = data
        end
      end
    end
  else
    global.secondary_chat.global.settings = config.global.settings
  end

  local info = global.secondary_chat.global.info
  if info then
    for table, child_table in pairs( config.global.info ) do
      info[table] = info[table] or {}
      for name, data in pairs( child_table ) do      
        if info[table][name] == nil or type(data) ~= type(info[table][name]) then
          info[table][name] = data
        end
      end
    end
  else
    global.secondary_chat.global.info = config.global.info
  end
end

function set_global_config_player(target)
  global.secondary_chat.players[target.index] = {}
  global.secondary_chat.players[target.index].settings = config.player.settings
  global.secondary_chat.players[target.index].info = config.player.info
  global.secondary_chat.players[target.index].gui = {}
  global.secondary_chat.players[target.index].gui.saves = {}
  global.secondary_chat.players[target.index].gui.saves.hidden = {}
  global.secondary_chat.players[target.index].autohide = max_time_autohide
  global.secondary_chat.players[target.index].blacklist = {}
  if not global.secondary_chat.state_chat then return end
  create_chat_gui(target)
end

function global_init()
  global.secondary_chat = global.secondary_chat or {}
  global.secondary_chat.state_chat = global.secondary_chat.state_chat or true
  global.secondary_chat.settings = global.secondary_chat.settings or {}
  global.secondary_chat.settings.limit_characters =  global.secondary_chat.settings.limit_characters or 73 * 14 --1022
  global.secondary_chat.players = global.secondary_chat.players or {}
  global.secondary_chat.global = global.secondary_chat.global or {}
  global.secondary_chat.global.settings = global.secondary_chat.global.settings or {}
  global.secondary_chat.global.info = global.secondary_chat.global.info or {}
  global.secondary_chat.global.list = global.secondary_chat.global.list or {}

  if global.secondary_chat.chats == nil then
    global.secondary_chat.chats = {}
    global.secondary_chat.chats.keys = {}
    global.secondary_chat.chats.list = {}
    global.secondary_chat.chats.data = {}
  end
  update_global_config()
end
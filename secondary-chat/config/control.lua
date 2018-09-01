configs = {}
configs.global = require('secondary-chat/config/global')
configs.player = require('secondary-chat/config/player')

function update_global_config_player(player)
  if global.secondary_chat.players[player.index] == nil then
    set_global_config_player(player)
    return 
  end

  global.secondary_chat.players[player.index].gui = global.secondary_chat.players[player.index].gui or {}
  global.secondary_chat.players[player.index].gui.saves = global.secondary_chat.players[player.index].gui.saves or {}
  global.secondary_chat.players[player.index].gui.saves.hidden = global.secondary_chat.players[player.index].gui.saves.hidden or {}
  global.secondary_chat.players[player.index].autohide = max_time_autohide
  global.secondary_chat.players[player.index].blacklist = global.secondary_chat.players[player.index].blacklist or {}

  local settings = global.secondary_chat.players[player.index].settings
  if settings then
    for table, child_table in pairs( configs.player.get_settings() ) do
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
    global.secondary_chat.players[player.index].settings = configs.player.get_settings()
  end

  local info = global.secondary_chat.players[player.index].info
  if info then
    for table, child_table in pairs( configs.global.get_info() ) do
      info[table] = info[table] or {}
      for name, data in pairs( child_table ) do      
        if info[table][name] == nil or type(data) ~= type(info[table][name]) then
          info[table][name] = data
        end
      end
    end
  else
    global.secondary_chat.players[player.index].info = configs.global.get_info()
  end

  if player.connected then
    if not global.secondary_chat.state_chat then return end
    create_chat_gui(player)
  end
end

function update_global_config()
  if global.secondary_chat.global == nil then
    global.secondary_chat.global = {}
    global.secondary_chat.global.settings = configs.global.get_settings()
    global.secondary_chat.global.info = configs.global.get_info()
  else
    local settings = global.secondary_chat.global.settings
    if settings then
      for table, child_table in pairs( configs.global.get_settings() ) do
        settings[table] = settings[table] or {}
        for name, data in pairs( child_table ) do      
          if settings[table][name] == nil or type(data) ~= type(settings[table][name]) then
            settings[table][name] = data
          end
        end
      end
    else
      global.secondary_chat.global.settings = configs.global.get_settings()
    end

    local info = global.secondary_chat.global.info
    if info then
      for table, child_table in pairs( configs.global.get_info() ) do
        info[table] = info[table] or {}
        for name, data in pairs( child_table ) do      
          if info[table][name] == nil or type(data) ~= type(info[table][name]) then
            info[table][name] = data
          end
        end
      end
    else
      global.secondary_chat.global.info = configs.global.get_info()
    end
  end

  global.secondary_chat.global.mutes = global.secondary_chat.global.mutes or {}
  global.secondary_chat.global.list = global.secondary_chat.global.list or {}
end

function set_global_config_player(target)
  local index = target.index
  global.secondary_chat.players[index] = {}
  global.secondary_chat.players[index].settings = configs.player.get_settings()
  global.secondary_chat.players[index].info = configs.player.get_info()
  global.secondary_chat.players[index].gui = {}
  global.secondary_chat.players[index].gui.saves = {}
  global.secondary_chat.players[index].gui.saves.hidden = {}
  global.secondary_chat.players[index].autohide = max_time_autohide
  global.secondary_chat.players[index].blacklist = {}

  if not global.secondary_chat.state_chat then return end
  create_chat_gui(target)
end

function global_init()
  global.secondary_chat = global.secondary_chat or {}
  global.secondary_chat.state_chat = global.secondary_chat.state_chat or true
  global.secondary_chat.settings = global.secondary_chat.settings or {}
  global.secondary_chat.settings.limit_characters = global.secondary_chat.settings.limit_characters or 73 * 14 --1022
  global.secondary_chat.players = global.secondary_chat.players or {}
  if game then
    for _, player in pairs( game.players ) do
      update_global_config_player(player)
    end
  end
  update_global_config()
  global.secondary_chat.chats = global.secondary_chat.chats or {}
end
remote.add_interface('secondary-chat',
{
  get_event_name = function(name)
    return chat_events[name]
  end,
  toggle = function(new_bool)
    if type(new_bool) ~= 'boolean' then return nil end

    local bool = {}
    bool.new = new_bool
    bool.old = global.secondary_chat.state_chat or false

    if bool.new == true and bool.old == false then
      add_commands()
      for _, player in pairs( game.players ) do
        create_chat_gui(player)
      end
      script.raise_event(chat_events.on_toggle, {state = true})
    elseif bool.new == false and bool.old == true then
      remove_commands()
      script.raise_event(chat_events.on_toggle, {state = false})
    else
      return false
    end

    global.secondary_chat.state_chat = bool.new
    return true
  end,
  get_state = function()
    return global.secondary_chat.state_chat
  end,
  get_global_data = function()
    return global.secondary_chat.global
  end,
  get_player_data = function(index)
    return global.secondary_chat.players[index]
  end,
  get_and_check_stance = function(target_1, target_2, stance)
    -- Validation of data
    if not (target_1 and target_1.valid) then return nil end
    if not (target_2 and target_2.valid) then return nil end

    -- Get and check stance
    if stance then
      local type = type(stance)
      if type == 'string' then
        local check = check_stance[stance]
        if check then
          return check(target_1, target_2)
        else
          return nil
        end
      elseif type == 'number' then
        local check = check_stance[get_name_stance(stance)]
        if check then
          return check(target_1, target_2)
        else
          return nil
        end
      else
        return nil
      end
    else
      for _, name in pairs( {'friend', 'neutral', 'enemy', 'specific'} ) do
        local check = check_stance[name]
        if check then
          if check(target_1, target_2) == true then
            return name
          end
        else
          log('Error with check_stance in secondary-chat')
        end
      end

      return 'unknown'
    end
  end,
  update_gui = function()
    update_chat_gui()
    return true
  end,
  function_send_message = function(name)
    return send_message[name]
  end,
  get_commands = function(name)
    return get_commands[name]
  end,
  function_change_list = function(name)
    return change_list[name]
  end,
  get_chat_data = function(name)
    return chats.data[name]
  end,
  get_gui_chat = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    return player.gui.left.table_chat
  end,
  add_chat = function(name, data)
    if chats.data[name] or type(data) ~= 'table' then return false end

    if update_chat(name, data) then
      for _, player in pairs( game.players ) do
        create_chat_gui(player)
      end
      return true
    else
      return false
    end
  end,
  remove_chat = function(name)
    local chat = chats.data[name]
    if chat == nil then return nil end

    if chat.interface.get_commands then
      local commands = remote.call(chat.interface.name, chat.interface.get_commands, name)
      for _, data in pairs( commands ) do
        remove_command(data.name)
      end
    end

    table.remove(chats.list, chats.keys[name])
    chats.keys[name] = nil
    chat = nil

    local index = 1
    for k, _ in pairs( chats.keys ) do
      chats.keys[k] = index
      index = index + 1
    end

    for _, player in pairs( game.players ) do
      create_chat_gui(player)
    end
  
    remove_command("toggle-chat")
    global.toggle_chat_commands = ""  
    for name, _ in pairs( chats.keys ) do
      global.toggle_chat_commands = global.toggle_chat_commands .. name .. '/'
    end
    add_command("toggle-chat", "secondary_chat.toggle", toggle_chat, global.toggle_chat_commands)

    script.raise_event(chat_events.on_delete_chat, {chat_name = name})

    return true
  end,
  update_chat = function(name, data)
    if chats.data[name] == nil or type(data) ~= 'table' then return false end

    if chat.interface.get_commands then
      local commands = remote.call(chat.interface.name, chat.interface.get_commands, name)
      for _, data in pairs( commands ) do
        remove_command(data.name)
      end
    end

    if update_chat(name, data) then
      for _, player in pairs( game.players ) do
        create_chat_gui(player)
      end

      remove_command("toggle-chat")
      global.toggle_chat_commands = ""  
      for name, _ in pairs( chats.keys ) do
        global.toggle_chat_commands = global.toggle_chat_commands .. name .. '/'
      end
      add_command("toggle-chat", "secondary_chat.toggle", toggle_chat, global.toggle_chat_commands)

      return true
    else
      script.raise_event(chat_events.on_delete_chat, {chat_name = name})
      return false
    end
  end,
  --[[add_command = function(name, description, func, addit_description)
    return add_command(name, description, func, addit_description)
  end,]]--
  --[[remove_command = function(name)
    return remove_command(name)
  end,]]--
  send_notice = function(message, player)
    -- Validation of data
    if not (player and player.valid) then return false end

    send_notice(message, player)
  end,
  get_gui_chat = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    return player.gui.left.table_chat
  end,
  get_gui_icons = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    local table_chat = player.gui.left.table_chat
    if table_chat == nil then return false end

    return table_chat.top_chat.icons
  end,
  get_gui_select_chat = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    local table_chat = player.gui.left.table_chat
    if table_chat == nil then return false end

    return table_chat.select_chat
  end,
  get_gui_table_select = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    local table_chat = player.gui.left.table_chat
    if table_chat == nil then return false end

    return table_chat.select_chat.table
  end,
  get_gui_table_filter = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    local table_chat = player.gui.left.table_chat
    if table_chat == nil then return false end

    return table_chat.select_chat.table_filter
  end,
  get_gui_notices = function(player)
    -- Validation of data
    if not (player and player.valid) then return false end

    local table_chat = player.gui.left.table_chat
    if table_chat == nil then return false end

    return table_chat.notices
  end
})
function toggle_drop_down(player)
  local table_chat = player.gui.left.table_chat
  if table_chat then
    local select_chat = table_chat.select_chat
    if select_chat then
      if select_chat.style.visible == nil then select_chat.style.visible = true end
      select_chat.style.visible = not select_chat.style.visible
    else
      log("not founded 'select_chat' for secondary chat")
    end
  else
    create_chat_gui(player)
  end
end

local function toggle_chat(cmd)
  local player = game.player
  if player == nil then return end
  local table_chat = player.gui.left.table_chat
  if cmd.parameter then
    if table_chat then
      local parameter = string.lower(cmd.parameter)
      local index = chats.keys[parameter]
      if index then
        toggle_chat_part(parameter)
      elseif parameter == "drop-down" then
        toggle_drop_down(player)
      else
        player.print({"secondary_chat.toggle", global.toggle_chat_commands})
      end
    else
      create_chat_gui(player)
    end
  else
    if table_chat then
      if table_chat.style.visible == nil then table_chat.style.visible = true end
      table_chat.style.visible = not table_chat.style.visible
      global.secondary_chat.players[player.index].settings.main.state_chat.state = table_chat.style.visible
    else
      create_chat_gui(game.player)
      global.secondary_chat.players[player.index].settings.main.state_chat.state = true
    end
  end
end

function remove_commands()
  for _, name in pairs( {"a", "allied-send", "l", "local-send", "toggle-chat"} ) do
    remove_command(name)
  end
end

function add_commands()
  for chat_name, chat in pairs( chats.data ) do
    if chat.gui.commands then
      for _, data in pairs( chat.gui.commands ) do
        add_command(data.name, data.description, function(cmd)
          local player = game.player
          if player == nil then return end 
          if cmd.parameter ~= nil then
            if not is_allow_message(cmd.parameter, player) then return end
            chats.data[chat_name].send_message(cmd.parameter, player)
          else
            player.print({data.description})
          end
        end)
      end
    end
  end

  global.toggle_chat_commands = ""  
  for name, _ in pairs( chats.keys ) do
    global.toggle_chat_commands = global.toggle_chat_commands .. name .. '/'
  end

  add_command("toggle-chat", "toggle", toggle_chat, global.toggle_chat_commands)
end

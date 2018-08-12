data = {}
data.chat = {}

data.chat['surface'] = function()
  chats.data['surface'] = {}
  chats.data['surface'].gui = {}
  chats.data['surface'].gui.commands = {{name = 'surface-send', description = 'secondary_chat.surface-send'}}
end

data.chat['local'] = function()
  chats.data['local'] = {}
  chats.data['local'].gui = {}
  chats.data['local'].gui.commands = {{name = 'l', description = 'secondary_chat.local-send'},
                                      {name = 'local-send', description = 'secondary_chat.local-send'}}
end

data.chat['allies'] = function()
  chats.data['allies'] = {}
  chats.data['allies'].gui = {}
  chats.data['allies'].gui.commands = {{name = 'a', description = 'secondary_chat.allied-send'},
                                       {name = 'allied-send', description = 'secondary_chat.allied-send'}}
end

data.chat['admins'] = function()
  chats.data['admins'] = {}
  chats.data['admins'].gui = {}
  chats.data['admins'].gui.commands = {{name = 'admins-send', description = 'secondary_chat.admins-send'}}
end

function init_chats()
  for name, _ in pairs( chats.keys ) do
    chats.data[name] = {}
    update_chat(name)
  end
end

function update_chat(name)
  update = data.chat[name]
  if update then
    update()
  end

  local chat = chats.data[name]
  chat.send_message = chat.send_message or send_message[name]
  if type(chat.send_message) ~= 'function' then
    chat = nil
    log('error: chats[' .. name .. '].send_message ~= function')
  else
    chat.allow_log = chat.allow_log or false
    chat.gui = chat.gui or {}
    chat.gui.is_have_state = chat.gui.is_have_state or false
    chat.gui.is_have_online = chat.gui.is_have_online or false
    chat.gui.change_list = chat.gui.change_list or change_list[name]
    if chat.gui.change_list ~= nil and type(chat.gui.change_list) ~= 'function' then
      chat.gui.change_list = nil
      log('error: chats[' .. name .. '].change_list ~= function')
    end
  end
end

send_message = {}

send_message['all'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  return sc_print_in_chat({"", player.name .. " (", {"command-output.shout"}, ")", {"colon"}, " ", input_message}, game, player)
end
send_message['surface'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  local message = {"", player.name .. " (", {"secondary_chat.to_surface"}, ")", {"colon"}, " ", input_message}
  local result = false
  for index, target in pairs ( game.players ) do
    if target.surface == player.surface and index ~= player.index then
      result = true
      sc_print_in_chat(message, target, player)
    end
  end

  if result then
    player.force.print(message, player.chat_color)
  else 
    player.print({"noone-to-reply"})
  end
  return result
end

send_message['faction'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  local drop_down = player.gui.left.table_chat.select_chat.table.select_drop_down
  local message

  if drop_down.style.visible then
    local target = game.forces[drop_down.items[drop_down.selected_index]]
    if target then
      if target ~= player.force then
        message = {"", player.name .. " | " .. player.force.name, {"colon"}, " ", input_message}
        sc_print_in_chat(message, target, player)
        message = {"", player.name .. "➟" .. target.name, {"colon"}, " ", input_message}
        sc_print_in_chat(message, player.force, player)
      else
        if global.secondary_chat.players[player.index].settings.main.with_tag.state then
          if player.tag ~= '' then
            message = {"", player.name .. " " .. player.tag, {"colon"}, " ", input_message}
            return sc_print_in_chat(message, player.force, player)
          else
            message = {"", player.name, {"colon"}, " ", input_message}
            return sc_print_in_chat(message, player.force, player)
          end
        else
          message = {"", player.name, {"colon"}, " ", input_message}
          return sc_print_in_chat(message, player.force, player)
        end
      end
    else
      player.print({"multiplayer.no-address", drop_down.items[drop_down.selected_index]})
    end
    return target
  else
    if global.secondary_chat.players[player.index].settings.main.with_tag.state then
      if player.tag ~= "" then
        message = {"", player.name .. " " .. player.tag, {"colon"}, " ", input_message}
        return sc_print_in_chat(message, player.force, player)
      else
        message = {"", player.name, {"colon"}, " ", input_message}
        return sc_print_in_chat(message, player.force, player)
      end
    else
      message = {"", player.name, {"colon"}, " ", input_message}
      return sc_print_in_chat(message, player.force, player)
    end
  end
end

send_message['local'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  local pos_p1 = player.position
  if type(input_message) == "string" and string.len(input_message) <= 80 then
    if string.len(input_message) <= 25 then
      player.surface.create_entity{name = "flying-text", position = pos_p1, text = input_message}
    else
      player.surface.create_entity{name = "flying-text-chat", position = pos_p1, text = input_message}
    end
  end

  for _, another_player in pairs (game.connected_players) do
    if player.surface == another_player.surface then
      local pos_p2 = another_player.position
      if ((pos_p1.x - pos_p2.x)^2 + (pos_p1.y - pos_p2.y)^2)^(0.5) <= 116 then
        sc_print_in_chat({"", player.name .. " (", {"secondary_chat.to_local"}, ")", {"colon"}, " ", input_message}, another_player, player)
      end
    end
  end
  return true
end

send_message['allies'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  local message = {"", player.name .. " (", {"secondary_chat.to_allies"}, ")", {"colon"}, " ", input_message}
  local result = false
  for _, force in pairs (game.forces) do
    if #force.players ~= 0 and player.force.get_friend(force) then
      result = true
      sc_print_in_chat(message, force, player)
    end
  end

  if result then
    player.force.print(message, player.chat_color)
  else 
    player.print({"noone-to-reply"})
  end
  return result
end

send_message['admins'] = function(input_message, player)
  script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
  local message

  if player.admin then
    message = {"", player.name .. " (", {"secondary_chat.to_admins"}, ")", {"colon"}, " ", input_message}
  else
    message = {"", player.name .. " (", {"secondary_chat.from_not_admin"}, ")", {"colon"}, " ", input_message}
  end

  local result = false
  for index, admin in pairs (game.players) do
    if admin.admin and index ~= player.index then
      sc_print_in_chat(message, admin, player)
      result = true
    end
  end

  if result then
    message = {"", player.name .. " (", {"secondary_chat.to_admins"}, ")", {"colon"}, " ", input_message}
    sc_print_in_chat(message, player, player)
  else
    if player.admin then
      player.print({"secondary_chat.sole_administrator"})
    else
      player.print({"secondary_chat.admins_not_founded"})
    end
  end
  return result
end

send_message['private'] = function(input_message, player)
  local drop_down = player.gui.left.table_chat.select_chat.table.select_drop_down
  local target = nil
  if drop_down.style.visible then
    target = game.players[drop_down.items[drop_down.selected_index]]
  end

  if target then
    local message = {"", player.name .. " (", {"command-output.whisper"}, ")", {"colon"}, " ", input_message}
    player.print(message)
    target.print(message)
  end
  return target
end

change_list = {}

change_list['private'] = function(gui, target, select_list, last_target)
  local items = {}
  local index = 0
  local new_selected_index
  last_target = last_target and game.players[last_target]
  for k, player in pairs( game.players ) do
    if target ~= player then 
      items[k] = player.name
    end
    index = index + 1
    if not new_selected_index and last_target and last_target == player then
      new_selected_index = index
    end
  end

  if #items > 0 then
    select_list.style.visible = true
    select_list.items = items
    select_list.selected_index = new_selected_index or 1
    return true
  else
    gui.selected_index = 0
    target.print({'noone-to-reply'})
    return false
  end
end

change_list['faction'] = function(gui, target, select_list, last_target)
  local items = {}
  local index = 0
  local new_selected_index
  for k, force in pairs( game.forces ) do
    last_target = last_target and game.forces[last_target]
    if #force.players > 0 then
      table.insert(items, k)
      index = index + 1
      if not new_selected_index then
        if last_target then
          if last_target == force then
            new_selected_index = index
          end
        else
          if target.force == force then
            new_selected_index = index
          end
        end
      end
    end
  end

  if #items > 1 then
    select_list.items = items
    select_list.selected_index = new_selected_index or 1
    select_list.style.visible = true
    return true
  elseif select_list.style.visible then
    select_list.items = {''}
    gui.selected_index = 1
    select_list.style.visible = false
    return false
  end
end

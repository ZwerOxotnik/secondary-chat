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
    --chat.gui.is_have_state = chat.gui.is_have_state or false
    --chat.gui.is_have_online = chat.gui.is_have_online or false
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
    if script.mod_name ~= 'level' then
      if string.len(input_message) <= 25 then
        player.surface.create_entity{name = "flying-text", position = pos_p1, text = input_message}
      else
        player.surface.create_entity{name = "flying-text-chat", position = pos_p1, text = input_message}
      end
    else
      player.surface.create_entity{name = "flying-text", position = pos_p1, text = input_message}
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

change_list['private'] = function(gui, target, select_list, last_target, drop_down_online, drop_down_state)
  if #game.players < 2 then
    gui.selected_index = 0
    target.print({'noone-to-reply'})
    drop_down_online.style.visible = false
    drop_down_state.style.visible = false
    return false
  end

  local list_players = {}
  if gui_online.keys['all'] == drop_down_online.selected_index then
    list_players = game.players
  elseif gui_online.keys['online'] == drop_down_online.selected_index then
    list_players = game.connected_players
  else -- gui_online.keys['offline']
    for _, player in pairs( game.players ) do
      if not player.connected then
        table.insert(list_players, player)
      end
    end
  end

  local check_stance = check_stance[get_name_stance(drop_down_state.selected_index)]
  local items = {}
  local new_selected_index
  local last_target = last_target and game.players[last_target]
  local index = 0
  for _, player in pairs( list_players ) do
    if check_stance(target.force, player.force) then
      if target ~= player then
        index = index + 1
        table.insert(items, player.name)
      end
      if not new_selected_index and last_target and last_target == player then
        new_selected_index = index
      end
    end
  end

  if #items > 0 then
    select_list.items = items
    select_list.selected_index = new_selected_index or 1
    drop_down_online.style.visible = true
    drop_down_state.style.visible = true
  else
    select_list.items = {''}
    select_list.selected_index = 1
  end
  select_list.style.visible = true
  drop_down_online.style.visible = true
  drop_down_state.style.visible = true
  return true
end

change_list['faction'] = function(gui, target, select_list, last_target, drop_down_online, drop_down_state)
  local is_more_than_2_force = function()
    local count = 0
    for _, force in pairs( game.forces ) do
      if #force.players ~= 0 then
        count = count + 1
        if count > 1 then
          return true
        end
      end
    end
    return false
  end

  if not is_more_than_2_force() then
    if select_list.style.visible then
      select_list.items = {''}
      select_list.selected_index = 1
      select_list.style.visible = false
    end
    drop_down_online.style.visible = false
    drop_down_state.style.visible = false
    return true
  end
  
  local list_forces = {}
  if gui_online.keys['all'] == drop_down_online.selected_index then
    list_forces = game.forces
  else
    local is_online = function( force )
      for _, player in pairs( force.players ) do
        if player.connected then return true end
      end
      return false
    end

    if gui_online.keys['online'] == drop_down_online.selected_index then
      for name, force in pairs( game.forces ) do
        if is_online(force) then
          list_forces[name] = force
        end
      end
    else -- gui_online.keys['offline']
      for name, force in pairs( game.forces ) do
        if not is_online(force) then
          list_forces[name] = force
        end
      end
    end
  end

  local check_stance = check_stance[get_name_stance(drop_down_state.selected_index)]
  local items = {}
  local new_selected_index
  local last_target = last_target and game.forces[last_target]
  local index = 0
  for name, force in pairs( list_forces ) do
    if #force.players > 0 and check_stance(target.force, force) then
      table.insert(items, name)
      index = index + 1
      if new_selected_index == nil then
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

  if #items > 0 then
    select_list.items = items
    select_list.selected_index = new_selected_index or 1
  else
    select_list.items = {''}
    select_list.selected_index = 1
  end
  select_list.style.visible = true
  drop_down_online.style.visible = true
  drop_down_state.style.visible = true
  return true
end

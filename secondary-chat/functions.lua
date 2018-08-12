function is_allow_message(message, sender)
  if string.len(message) < global.secondary_chat.settings.limit_characters then
    return true
  else
    log({"", sender.name .. " > ", {"secondary_chat.long_message"}})
    sender.print({"", "~~~~ ", {"secondary_chat.long_message"}, " ~~~~"})
    return false
  end
end

function sc_print_in_chat(message, receiver, sender)    
  -- TODO: blacklist
  receiver.print(message, sender.chat_color)
  return true
end

function is_force_have_allies(target)
  for _, force in pairs (game.forces) do
    if #force.players ~= 0 and target.get_friend(force) then
      return true
    end
  end
  return false
end

function check_and_get_chat_number(name)
  if type(chats.keys[name]) == "number" then
    return chats.keys[name]
  else
    log("chat '" .. name .. "' not found for secondary-chat")
    return nil
  end
end

function check_and_get_chat_name(name)
  if type(chats.keys[name]) == "number" then
    return name
  else
    log("chat '" .. name .. "' not found for secondary-chat")
    return nil
  end
end

function get_name_chat(index)
  for name, index_chat in pairs( chats.keys ) do
    if index_chat == index then
      return name
    end
  end
  return nil
end

function get_name_stance(index)
  for name, index_chat in pairs( gui_state.keys ) do
    if index_chat == index then
      return name
    end
  end
  return nil
end

check_stance = {}
check_stance['all'] = function()
  return true
end
check_stance['friend'] = function(force, other_force)
  if (force.get_cease_fire(other_force) and other_force.get_cease_fire(force)) and (force.get_friend(other_force) and other_force.get_friend(force)) then
    return true
  end
  return false
end
check_stance['neutral'] = function(force, other_force)
  if (force.get_cease_fire(other_force) and other_force.get_cease_fire(force)) and (not force.get_friend(other_force) and not other_force.get_friend(force)) then
    return true
  end
  return false
end
check_stance['enemy'] = function(force, other_force)
  if (not force.get_cease_fire(other_force) and not other_force.get_cease_fire(force)) and (not force.get_friend(other_force) and not other_force.get_friend(force)) then
    return true
  end
  return false
end
check_stance['specific'] = function(force, other_force)
  if force.get_cease_fire(other_force) ~= other_force.get_cease_fire(force) or force.get_friend(other_force) ~= other_force.get_friend(force) then
    return true
  end
  return false
end

function add_command(name, description, f, addit_description)
  if type(f) == "function" then
    if commands.game_commands[name] == nil and commands.commands[name] == nil then
      commands.add_command(name, {description, addit_description}, f)
      return true
    else
      log("command '" .. name .. "' not added for secondary-chat")
      return false
    end
  else
    log("Function for '" .. name .. "' not found for secondary-chat")
  end
end

function remove_command(name)
  return commands.commands[name] and commands.remove_command(name)
end

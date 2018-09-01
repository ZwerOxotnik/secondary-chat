-- secondary chat
-- Copyright (c) ZwerOxotnik 2018
-- The MIT License (MIT)
-- Source: https://gitlab.com/ZwerOxotnik/secondary-chat
-- Homepage: https://mods.factorio.com/mod/secondary-chat

local mod = {}

chats = {}
chat_events =
{
  on_console_chat = script.generate_event_name(),
  toggle = script.generate_event_name()
}

max_time_autohide = 60 * 60 * 10

color_picker = require('secondary-chat/integrations/color-picker')
require("secondary-chat/config/control")
require('secondary-chat/functions')
require('secondary-chat/gui/control')
require('secondary-chat/commands')
require('secondary-chat/chats/control')
if script.mod_name ~= 'level' then
  require('secondary-chat/buttons-control')
end

remote.add_interface('secondary-chat',
{
  get_event_name = function(name)
    return chat_events[name]
  end,
  toggle = function(new_bool)
    if type(new_bool) ~= 'boolean' then return end

    local bool = {}
    bool.new = new_bool
    bool.old = global.secondary_chat.state_chat or false

    if bool.new == true and bool.old == false then
      add_commands()
      for _, player in pairs( game.players ) do
        create_chat_gui(player)
      end
      script.raise_event(chat_events.toggle, {state = true})
    elseif bool.new == false and bool.old == true then
      remove_commands()
      script.raise_event(chat_events.toggle, {state = false})
    else
      return false
    end

    global.secondary_chat.state_chat = bool.new
    return true
  end,
  get_state = function()
    return global.secondary_chat.state_chat
  end,
  --[[get_settings = function(wip)
    
  end,]]
  --[[set_settings = function(wip)
    
  end,]]--
  update_gui = function()
    update_chat_gui()
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
  --[[add_chat = function(wip)
    
  end,]]
  --[[remove_chat = function(wip)
    
  end,]]
  --[[update_chat = function(wip)
    
  end,]]
  --[[add_command = function(wip)
    
  end,]]
  --[[remove_command = function(wip)
    
  end]]
  -- etc.
})

mod.on_configuration_changed = function(event)
  update_global_config()
  for _, player in pairs( game.players ) do
    update_global_config_player(player)
  end
  init_chats()
end

mod.on_gui_click = function(event)
  -- Validation of data
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if (gui.name == "print_in_chat" or string.match(gui.name, "chat_(.+)")) then
    if event.shift then
      click_gui_chat(event, true)
    elseif event.control then
      local table_chat = player.gui.left.table_chat
      table_chat.top_chat.chat_text_box.text = table_chat.last_messages.last.text
    else
      click_gui_chat(event)
    end
  else
    click_gui_chat(event)
  end
end

mod.color_picker_ok_pressed = function(event)
  color_picker.ok_pressed(event)
end

mod.on_player_created = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  --set_global_config_player(player)
end

mod.on_player_removed = function(event)
  global.secondary_chat.players[event.player_index] = nil
  global.secondary_chat.global.mutes[event.player_index] = nil

  update_chat_gui()
end

mod.on_gui_text_changed = function(event)
  -- Validation of data
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if gui.name == 'chat_text_box' and gui.parent.parent.name == 'table_chat' then
    if string.byte(gui.text, -1) == 10 then
      if #gui.text > 2 then
        event.element = gui.parent.parent.select_chat.table.print_in_chat
        click_gui_chat(event)
      end
      gui.text = ''
    end
  end
end

mod.on_gui_checked_state_changed = function(event)
  -- Validation of data
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  local parametr = string.match(gui.name, "(.+)_boolean")
  if parametr then
    update_checkbox(player, gui, parametr)
  end
end

mod.on_gui_selection_state_changed = function(event)
  -- Validation of data
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if gui.parent.parent.name == 'select_chat' then
    if gui.parent.name == 'table_filter' then
      update_chat_and_drop_down(gui.parent.parent.table.chat_drop_down, player)
    elseif gui.name == 'chat_drop_down' then
      update_chat_and_drop_down(gui, player)
    end
  end
end

mod.on_player_promoted = function(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  check_settings(player)
end

mod.on_player_demoted = function(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  check_settings(player)
end

mod.on_round_start = function()
  if not global.secondary_chat.state_chat then return end

  -- Create gui of chat
  for _, player in pairs( game.players ) do
    create_chat_gui(player)
  end
end

mod.on_round_end = function()
  if not global.secondary_chat.state_chat then return end

  -- Destroy gui of chat
  for _, player in pairs( game.players ) do
    destroy_chat_gui(player)
  end
end


mod.on_init = function()
  global_init()

  chats = global.secondary_chat.chats
  init_chats()
  add_commands()
end

mod.on_load = function()
  if not game then
    if global.secondary_chat == nil then
      global_init()
    end

    chats = global.secondary_chat.chats
    if chats.keys == nil then
      init_chats()
    end
    add_commands()
  end
end

mod.on_player_joined_game = function(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if global.secondary_chat.players[event.player_index] then
    color_picker.destroy_gui(player)

    -- Remove settings
    local frame = player.gui.center.secondary_chat_settings
    if frame then
      frame.destroy()
    end

    local table_chat = player.gui.left.table_chat
    local settings = global.secondary_chat.players[event.player_index].settings
    if table_chat then
      table_chat.style.visible = settings.main.state_chat.state
      table_chat.top_chat.icons.color.style.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker16"] ~= nil or remote.interfaces["color-picker"] ~= nil))
    elseif settings.main.state_chat.state and not global.secondary_chat.state_chat then
      create_chat_gui(player)
    end
  else
    set_global_config_player(player)
  end

  update_chat_gui()
end

mod.on_player_left_game = function(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  color_picker.destroy_gui(player)

  -- Hide chat
  local table_chat = player.gui.left.table_chat
  if table_chat then
    table_chat.style.visible = false
  end

  -- Remove settings
  local frame = player.gui.center.secondary_chat_settings
  if frame then
    frame.destroy()
  end

  global.secondary_chat.players[event.player_index].autohide = max_time_autohide
end

mod.on_player_changed_force = function(event)
  update_chat_gui()
end

mod.on_forces_merging = function(event)
  update_chat_gui()
end

mod.on_player_display_resolution_changed = function(event)
  check_settings_frame_size(event)
end

-- For soft-mods, scenarios, interfaces
mod.delete = function(event)
  remove_commands()
  for _, player in pairs( game.players ) do
    destroy_chat_gui(player)
    color_picker.destroy_gui(player)
  end
  remote.remove_interface('secondary-chat')
  global.secondary_chat = nil
end

if script.mod_name ~= 'level' then
  mod.autohide = function(event)
    local data = global.secondary_chat.players
    for index, player in pairs( game.connected_players ) do
      local table_chat = player.gui.left.table_chat
      if table_chat and table_chat.style.visible then
        if data[index].autohide <= 0 then
          table_chat.style.visible = false
        else
          data[index].autohide = data[index].autohide - (60 * 60)
        end
      else
        data[index].autohide = max_time_autohide
      end
    end
  end
end

mod.on_player_muted = function(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  global.secondary_chat.global.mutes[event.player_index] = true
end

mod.on_player_unmuted = function(event)  
  global.secondary_chat.global.mutes[event.player_index] = nil
end

return mod

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
  toggle = function(bool)
    if bool == nil then return nil end
    local old_state = global.secondary_chat.state_chat or false

    if bool == true and old_state == true then
      add_commands()
      for _, player in pairs( game.players ) do
        create_chat_gui(player)
      end
      script.raise_event(chat_events.toggle, {state = true})
    elseif bool == false and old_state == false then
      remove_commands()
      script.raise_event(chat_events.toggle, {state = false})
    end

    new_state = bool
    global.secondary_chat.state_chat = new_state
  end,
  get_state = function()
    return global.secondary_chat.state_chat
  end,
  --[[get_settings = function(wip)
    
  end,]]
  --[[set_settings = function(wip)
    
  end,]]--
  update_gui = function()
    for _, player in pairs( game.connected_players ) do
      local table_chat = player.gui.left.table_chat
      if table_chat and table_chat.style.visible ~= false then
        create_chat_gui(player)
      end
    end
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
})

mod.on_configuration_changed = function(event)

end

mod.on_gui_click = function(event)
  if not (event and event.element and event.element.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local gui = event.element
  if (gui.name == "print_in_chat" or string.match(gui.name, "chat_(.+)")) then
    if event.shift then
      click_gui_chat(event, true)
    elseif event.control then
      local table_chat = player.gui.left.table_chat
      table_chat.top.chat_text_box.text = table_chat.last_messages.last.text
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
  update_global_config_player(player)
end

mod.on_player_removed = function(event)
  global.secondary_chat.players[event.player_index] = nil
  update_chat_gui()
end

mod.on_gui_checked_state_changed = function(event)
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
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if gui.name == 'chat_drop_down' and gui.parent.parent.name == 'select_chat' then
    update_chat_and_drop_down(gui, player)
  end
end

mod.on_player_promoted = function(event)
  local player = game.players[event.player_index]
  local table_chat = player.gui.left.table_chat
  if table_chat and table_chat.settings.style.visible then
    create_settings_chat_of_admin(player, table_chat.settings)
  end
end

mod.on_player_demoted = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  local table_chat = player.gui.left.table_chat
  if table_chat and table_chat.settings.admin then
    table_chat.settings.admin.clear()
  end
end

mod.on_round_start = function()
  if not global.secondary_chat.state_chat then return end

  for _, player in pairs( game.players ) do
    create_chat_gui(player)
  end
end

mod.on_round_end = function()
  if not global.secondary_chat.state_chat then return end

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
  if global.secondary_chat and global.secondary_chat.chats then
    chats = global.secondary_chat.chats
    add_commands()
  end
end

mod.on_player_joined_game = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  if global.secondary_chat.players[event.player_index] then
    color_picker.destroy_gui(player)
    local table_chat = player.gui.left.table_chat
    if table_chat then
      table_chat.style.visible = global.secondary_chat.players[event.player_index].settings.main.state_chat.state
      table_chat.top.color.style.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker16"] ~= nil or remote.interfaces["color-picker"] ~= nil))
    elseif global.secondary_chat.players[event.player_index].settings.main.state_chat.state and not global.secondary_chat.state_chat then
      create_chat_gui(player)
    end
  else
    update_global_config_player(player)
  end

  update_chat_gui()
end

mod.on_player_left_game = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  color_picker.destroy_gui(player)

  local table_chat = player.gui.left.table_chat
  if table_chat then
    table_chat.style.visible = false
  end
end

mod.on_player_changed_force = function(event)
  update_chat_gui()
end

mod.on_forces_merging = function(event)
  update_chat_gui()
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

return mod

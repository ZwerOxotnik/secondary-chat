local secondary_chat = require("secondary-chat/control")

script.on_configuration_changed(secondary_chat.on_configuration_changed)
script.on_event(defines.events.on_gui_click, secondary_chat.on_gui_click)
script.on_event(defines.events.on_player_created, secondary_chat.on_player_created)
script.on_event(defines.events.on_player_removed, secondary_chat.on_player_removed)
script.on_event(defines.events.on_gui_selection_state_changed, secondary_chat.on_gui_selection_state_changed)
script.on_event(defines.events.on_forces_merging, secondary_chat.on_forces_merging)
script.on_event(defines.events.on_player_changed_force, secondary_chat.on_player_changed_force)
script.on_event(defines.events.on_player_joined_game, secondary_chat.on_player_joined_game)
script.on_event(defines.events.on_player_promoted, secondary_chat.on_player_promoted)
script.on_event(defines.events.on_player_demoted, secondary_chat.on_player_demoted)
script.on_event(defines.events.on_gui_checked_state_changed, secondary_chat.on_gui_checked_state_changed)
script.on_event(defines.events.on_player_display_resolution_changed, secondary_chat.on_player_display_resolution_changed)
script.on_event(defines.events.on_gui_text_changed, secondary_chat.on_gui_text_changed)
script.on_event(defines.events.on_player_muted, secondary_chat.on_player_muted)
script.on_event(defines.events.on_player_unmuted, secondary_chat.on_player_unmuted)

local function find_interface(interfaces)
  for _, name in pairs( interfaces ) do
    if remote.interfaces[name] then
      return name
    end
  end
  return nil
end

local function on_round_start()
  secondary_chat.on_round_start()
end

local function on_round_end()
  secondary_chat.on_round_end()
end

local function color_picker_ok_pressed(event)
  secondary_chat.color_picker_ok_pressed(event)
end

local function on_load()
  secondary_chat.on_load()

  -- Searching events "on_round_start" and "on_round_end"
  for interface, _ in pairs( remote.interfaces ) do
    local function_name = "get_event_name"
    if remote.interfaces[interface][function_name] then
      local ID_1 = remote.call(interface, function_name, "on_round_start")
      local ID_2 = remote.call(interface, function_name, "on_round_end")
      if (type(ID_1) == "number") and (type(ID_2) == "number") then
        if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
          script.on_event(ID_1, on_round_start)
          script.on_event(ID_2, on_round_end)
        end
      end
    end
  end

  -- Searching event "on_ok_button_clicked" from a mod "color-picker"
  local interface = find_interface({"color-picker", "color-picker16"})
  if interface then
    local ID_1 = remote.call(interface, "on_ok_button_clicked")
    if (type(ID_1) == "number" and script.get_event_handler(ID_1) == nil) then
      script.on_event(ID_1, color_picker_ok_pressed)
    end
  end
end
script.on_load(on_load)

if script.mod_name ~= 'level' then
  script.on_nth_tick(60 * 60, secondary_chat.autohide)
end

local function on_init()
  secondary_chat.on_init()

  on_load()
end
script.on_init(on_init)

--[[
Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the EUPL, Version 1.2 only (the "LICENCE");
Author: ZwerOxotnik
Version: 1.19.1 (2019-03-05)

Description: Adds gui of chat, new commands, new types of chat, new interactions.

You can write and receive any information on the links below.
Source: https://gitlab.com/ZwerOxotnik/secondary-chat
Mod portal: https://mods.factorio.com/mod/secondary-chat
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64625

]]--

local module = {}
module.version = "1.19.2"
local BUILD = 1500 -- Always to increment the number when change the code

chats = {}

max_time_autohide = 60 * 60 * 10 -- 10 min

require('secondary-chat/self_events')
color_picker = require('secondary-chat/integrations/color-picker')
require("secondary-chat/config/control")
require('secondary-chat/functions')
require('secondary-chat/gui/control')
require('secondary-chat/commands')
require('secondary-chat/chats/control')
if script.mod_name ~= 'level' then
	require('secondary-chat/mod-buttons')
end
require('secondary-chat/interface')

local function on_configuration_changed()
	update_global_config()

	for _, player in pairs( game.players ) do
		update_global_config_player(player)
	end
end

local function on_gui_click(event)
	-- Validation of data
	local gui = event.element
	if not (gui and gui.valid) then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	if (gui.name == "print_in_chat" or string.match(gui.name, "chat_(.+)")) then
		press_button_send_chat(event)
	else
		click_gui_chat(event)
	end
end

module.color_picker_ok_pressed = function(event)
	color_picker.ok_pressed(event)
end

local function on_player_removed(event)
	script.raise_event(chat_events.on_pre_delete_player_data, {player_index = event.player_index})

	global.secondary_chat.players[event.player_index] = nil
	global.secondary_chat.global.mutes[event.player_index] = nil

	update_chat_gui()
end

local function on_gui_text_changed(event)
	-- Validation of data
	local gui = event.element
	if not (gui and gui.valid) then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	if gui.name == 'chat_text_box' and gui.parent.parent.parent.name == 'table_chat' then
		if string.byte(gui.text, -1) == 10 then
			if #gui.text > 2 then
				event.element = gui.parent.parent.parent.select_chat.table.print_in_chat
				player_send_message(event)

				-- unfocus for the gui
				text_box = create_chat_text_box(gui.parent)

				if global.secondary_chat.players[event.player_index].settings.main.auto_focus.state then
					text_box.focus()
				end
			else
				-- unfocus for the gui
				create_chat_text_box(gui.parent)
			end
		end
	end
end

local function on_gui_checked_state_changed(event)
	-- Validation of data
	local gui = event.element
	if not (gui and gui.valid and gui.parent.parent.parent) then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	if gui.parent.name == 'config_table' and (gui.parent.parent.parent.name == 'settings' or gui.parent.parent.parent.parent.name == 'settings') then
		local parameter = string.match(gui.name, "(.+)_boolean")
		if parameter then
			update_checkbox(player, gui, parameter)
			return
		end

		local parameter = string.match(gui.name, "(.+)-allow_show_fast") 
		if parameter then 
			update_allow_show_fast(player, gui, parameter)
			return 
		end
	end
end

local function on_gui_selection_state_changed(event)
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

local function on_player_promoted(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	check_settings(player)
end

local function on_player_demoted(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	check_settings(player)
end

local function load()
	chats = global.secondary_chat.chats
	if not game then
		if global.secondary_chat.state_chat == true then
			add_commands()
		end
	end

	local on_round_start = function()
		if not global.secondary_chat.state_chat then return end

		-- Create gui of chat
		for _, player in pairs( game.players ) do
			create_chat_gui(player)
		end
	end
	local on_round_end = function()
		if not global.secondary_chat.state_chat then return end

		-- Destroy gui of chat
		for _, player in pairs( game.players ) do
			destroy_chat_gui(player)
		end
	end

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

    local function pick_interface(interfaces)
        for _, name in pairs( interfaces ) do
            if remote.interfaces[name] then
                return name
            end
        end

        return nil
    end

	-- Searching event "on_ok_button_clicked" from a mod "color-picker"
	local interface = pick_interface({"color-picker"})
	if interface then
		local ID_1 = remote.call(interface, "on_ok_button_clicked")
		if (type(ID_1) == "number" and script.get_event_handler(ID_1) == nil) then
			script.on_event(ID_1, modules.secondary_chat.color_picker_ok_pressed)
		end
	end
end

local function init()
	global_init()
	load()

	if global.secondary_chat.state_chat == true then
		add_commands()
	end
end

local function on_player_joined_game(event)
	if script.mod_name == 'level' and global.secondary_chat.build ~= BUILD then
		global_init()
		global.secondary_chat.build = BUILD
	end

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
			table_chat.visible = settings.main.state_chat.state
			table_chat.top_chat.icons.color.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker"] ~= nil))
		elseif settings.main.state_chat.state and not global.secondary_chat.state_chat then
			create_chat_gui(player)
		end
	else
		update_global_config_player(player)
	end

	update_chat_gui()
end

local function on_player_created()
	-- Delete previous chat GUI
	if #global.secondary_chat.players == 0 then
		for _, player in pairs( game.players ) do
			destroy_chat_gui(player)
		end
	end
end

local function on_player_left_game(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	color_picker.destroy_gui(player)

	-- Hide chat
	local table_chat = player.gui.left.table_chat
	if table_chat then
		table_chat.visible = false
	end

	-- Remove settings
	local frame = player.gui.center.secondary_chat_settings
	if frame then
		frame.destroy()
	end

	global.secondary_chat.players[event.player_index].autohide = max_time_autohide
end

-- For soft-mods, scenarios, interfaces
module.delete = function(event)
	script.raise_event(chat_events.on_pre_remove_mod)

	remove_commands()
	for _, player in pairs( game.players ) do
		destroy_chat_gui(player)
		color_picker.destroy_gui(player)
	end
	remote.remove_interface('secondary-chat')
	global.secondary_chat = nil
end

local function on_player_muted(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	global.secondary_chat.global.mutes[event.player_index] = true
end

local function on_player_unmuted(event)
	global.secondary_chat.global.mutes[event.player_index] = nil
end

module.events = {
	on_init = init,
	on_load = load,
	on_configuration_changed = on_configuration_changed,
	on_gui_selection_state_changed = on_gui_selection_state_changed,
	on_player_display_resolution_changed = check_settings_frame_size,
	on_gui_checked_state_changed = on_gui_checked_state_changed,
	on_gui_text_changed = on_gui_text_changed,
	on_gui_click = on_gui_click,
	on_player_created = on_player_created,
	on_player_removed = on_player_removed,
	on_player_joined_game = on_player_joined_game,
	on_player_left_game = on_player_left_game,
	on_player_changed_force = update_chat_gui,
	on_forces_merging = update_chat_gui,
	on_player_promoted = on_player_promoted,
	on_player_demoted = on_player_demoted,
	on_player_muted = on_player_muted,
	on_player_unmuted = on_player_unmuted,
}

if script.mod_name ~= 'level' then
	module.custom_events = {
		autohide = function(event)
			local data = global.secondary_chat.players
			for index, player in pairs( game.connected_players ) do
				local table_chat = player.gui.left.table_chat
				if table_chat and table_chat.visible then
					if data[index].autohide <= 0 then
						table_chat.visible = false
						script.raise_event(chat_events.on_hide_gui_chat, {player_index = index, container = table_chat})
					else
						data[index].autohide = data[index].autohide - (60 * 60)
					end
				else
					data[index].autohide = max_time_autohide
				end
			end
		end
	}
end

return module

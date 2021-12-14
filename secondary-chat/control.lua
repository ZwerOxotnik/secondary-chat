--[[
Copyright (C) 2017-2021 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the EUPL, Version 1.2 only (the "LICENCE");
Author: ZwerOxotnik

You can write and receive any information on the links below.
Source: https://gitlab.com/ZwerOxotnik/secondary-chat
Mod portal: https://mods.factorio.com/mod/secondary-chat
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64625

]]--

local module = {}
module.version = "1.25.0"
module.events = {}
local BUILD = 3100 -- Always to increment this number when change the code

local match = string.match

chats = {}

max_autohide_time = 60 * 60 * 10 -- 10 min

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

module.on_configuration_changed = function()
	delete_old_chat()
	update_global_config()

	for _, player in pairs( game.players ) do
		update_global_config_player(player)
	end
end

local function press_button_send_chat(event)
	if event.shift then
		player_send_message(event, true)
	elseif event.control then
		local player = game.get_player(event.player_index)
		local table_chat = player.gui.screen.chat_main_frame.table_chat
		table_chat.top_chat.chat_table.chat_text_box.text = table_chat.last_messages.last.text
	else
		player_send_message(event)
	end
end

local function on_gui_click(event)
	local element = event.element
	if (element.name == "print_in_chat" or match(element.name, "chat_(.+)")) then
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

	local secondary_chat = global.secondary_chat
	secondary_chat.players[event.player_index] = nil
	secondary_chat.global.mutes[event.player_index] = nil

	update_chat_gui()
end

local function on_gui_text_changed(event)
	-- Validation of data
	local element = event.element
	if element.name == 'chat_text_box' and element.parent.parent.parent.name == 'table_chat' then
		if string.byte(element.text, -1) == 10 then
			if #element.text > 1 then
				element.text = element.text:sub(1, -2)
				event.element = element.parent.parent.parent.select_chat.interactions.print_in_chat
				player_send_message(event)

				-- unfocus for the gui
				local text_box = create_chat_text_box(element.parent)

				if global.secondary_chat.players[event.player_index].settings.main.auto_focus.state then
					text_box.focus()
				end
			else
				-- unfocus for the gui
				create_chat_text_box(element.parent)
			end
		end
		return true
	end
end

local function on_gui_checked_state_changed(event)
	local element = event.element
	if element.parent.name == 'config_table' and (element.parent.parent.parent.name == 'settings' or element.parent.parent.parent.parent.name == 'settings') then
		local parameter = match(element.name, "(.+)_boolean")
		if parameter then
			update_checkbox(game.get_player(event.player_index), element, parameter)
			return true
		end

		parameter = match(element.name, "(.+)-allow_fast_show")
		if parameter then
			update_allow_fast_show(game.get_player(event.player_index), element, parameter)
			return true
		end
	end
end

local function on_gui_selection_state_changed(event)
	if event.element.parent.parent.name ~= 'select_chat' then return end

	local element = event.element
	if element.parent.name == 'table_filter' then
		update_chat_and_drop_down(element.parent.parent.interactions.chat_drop_down, game.get_player(event.player_index))
		return true
	elseif element.name == 'chat_drop_down' then
		update_chat_and_drop_down(element, game.get_player(event.player_index))
		return true
	elseif element.name == 'targets_drop_down' then
		local chat_name = get_chat_name(element.parent.parent.interactions.chat_drop_down.selected_index)
		script.raise_event(chat_events.on_update_chat_and_drop_down, {player_index = event.player_index, chat_name = chat_name, target = element.items[element.selected_index]})
		return true
	end
end

local function on_player_promoted(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	check_settings(player)
end

local function on_player_demoted(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	check_settings(player)
end

module.on_load = function()
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
	for interface_name, _ in pairs( remote.interfaces ) do
		local function_name = "get_event_name"
		if remote.interfaces[interface_name][function_name] then
			local ID_1 = remote.call(interface_name, function_name, "on_round_start")
			local ID_2 = remote.call(interface_name, function_name, "on_round_end")
			if (type(ID_1) == "number") and (type(ID_2) == "number") then
				if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
					table.insert(module.events, ID_1, on_round_start)
					table.insert(module.events, ID_2, on_round_end)
					-- script.on_event(ID_1, on_round_start)
					-- script.on_event(ID_2, on_round_end)
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
			table.insert(module.events, ID_1, module.color_picker_ok_pressed)
			-- script.on_event(ID_1, module.color_picker_ok_pressed)
		end
	end
end

module.on_init = function()
	global_init()
	module.on_load()

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
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	if global.secondary_chat.players[event.player_index] then
		color_picker.destroy_gui(player)

		-- Remove settings
		local frame = player.gui.center.secondary_chat_settings
		if frame then
			frame.destroy()
		end

		local chat_main_frame = player.gui.screen.chat_main_frame
		local settings = global.secondary_chat.players[event.player_index].settings
		if chat_main_frame then
			chat_main_frame.visible = settings.main.state_chat.state
			chat_main_frame.table_chat.top_chat.icons.color.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker"] ~= nil))
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
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	color_picker.destroy_gui(player)

	-- Hide chat
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		chat_main_frame.visible = false
	end

	-- Remove settings
	local frame = player.gui.center.secondary_chat_settings
	if frame then
		frame.destroy()
	end

	global.secondary_chat.players[event.player_index].autohide = max_autohide_time
end

-- For soft-mods, scenarios, interfaces (not tested)
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
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	-- Mute the player
	global.secondary_chat.global.mutes[event.player_index] = true
end

local function on_player_unmuted(event)
	-- Unmute the player
	global.secondary_chat.global.mutes[event.player_index] = nil
end

local function check_settings_frame_size(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	local frame = player.gui.center.secondary_chat_settings
	if not frame then return end
	create_settings_for_everything(player)
end


module.events = {
	[defines.events.on_gui_selection_state_changed] = function(e) pcall(on_gui_selection_state_changed, e) end,
	[defines.events.on_player_display_resolution_changed] = check_settings_frame_size,
	[defines.events.on_gui_checked_state_changed] = function(e) pcall(on_gui_checked_state_changed, e) end,
	[defines.events.on_gui_text_changed] = function(e) pcall(on_gui_text_changed, e) end,
	[defines.events.on_gui_click] = function(e) pcall(on_gui_click, e) end,
	[defines.events.on_player_created] = on_player_created,
	[defines.events.on_player_removed] = on_player_removed,
	[defines.events.on_player_joined_game] = on_player_joined_game,
	[defines.events.on_player_left_game] = on_player_left_game,
	[defines.events.on_player_changed_force] = update_chat_gui,
	[defines.events.on_forces_merging] = update_chat_gui,
	[defines.events.on_player_promoted] = on_player_promoted,
	[defines.events.on_player_demoted] = on_player_demoted,
	[defines.events.on_player_muted] = on_player_muted,
	[defines.events.on_player_unmuted] = on_player_unmuted
}

-- TODO: Test it
if script.mod_name ~= 'level' then
	local function autohide_GUI()
		local secondary_chat = global.secondary_chat
		local data = secondary_chat.players
		for player_index, player in pairs( game.connected_players ) do
			local player_data = data[player_index]
			if player_data.settings.main.auto_hide.state then
				local chat_main_frame = player.gui.screen.chat_main_frame
				if chat_main_frame and chat_main_frame.visible then
					if player_data.autohide <= 0 then
						chat_main_frame.visible = false
						script.raise_event(chat_events.on_hide_gui_chat, {player_index = player_index, container = chat_main_frame})
					else
						player_data.autohide = player_data.autohide - (60 * 60)
					end
				else
					player_data.autohide = max_autohide_time
				end
			end
		end
	end

	module.on_nth_tick = {
		[60 * 60] = autohide_GUI
	}
end

return module

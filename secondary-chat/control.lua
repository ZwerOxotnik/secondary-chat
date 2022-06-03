--[[
Copyright (C) 2017-2022 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the EUPL, Version 1.2 only (the "LICENCE");
Author: ZwerOxotnik

You can write and receive any information on the links below.
Source: https://gitlab.com/ZwerOxotnik/secondary-chat
Mod portal: https://mods.factorio.com/mod/secondary-chat
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64625

]]--

local M = {}


require('secondary-chat/self_events')
color_picker = require('secondary-chat/integrations/color-picker')
require("secondary-chat/config/control")
require('secondary-chat/functions')
require('secondary-chat/gui/control')
require('secondary-chat/commands')
require('secondary-chat/chats/control')
require('secondary-chat/mod-buttons')
require('secondary-chat/interface')


--#region Global data
local mod_data
---@type table<number, table>
local players_data
---@type table<string, table<number, string>>
local chat_logs
chats = {}
--#endregion


--#region Constants
local draw_text = rendering.draw_text
local print_to_rcon = rcon.print
local match = string.match
local floor = math.floor
local call = remote.call
local FLOW = {type = "flow"}
local RED_COLOR = {1, 0, 0}
local CLOSE_BUTTON = {
	type = "sprite-button",
	name = "SChat_close",
	style = "frame_action_button",
	sprite = "utility/close_white",
	hovered_sprite = "utility/close_black",
	clicked_sprite = "utility/close_black"
}
MAX_AUTOHIDE_TIME = 60 * 60 * 10 -- 10 min
--#endregion


--#region Function for RCON

---@param name string
function getRconData(name)
	print_to_rcon(game.table_to_json(mod_data[name]))
end

--#endregion

---Format: hh:mm
---@param tick number
---@return string
function ticks_to_time(tick)
	local mins = floor(tick / (60 * 60))
	local hours = floor(mins / 60)
	mins = mins - hours * 60

	if hours < 9 then
		if hours == 0 then
			hours = "00"
		else
			hours = "0" .. hours
		end
	end

	if mins < 9 then
		if mins == 0 then
			mins = "00"
		else
			mins = "0" .. mins
		end
	end

	return hours .. ":" .. mins
end


---@param nickname string
---@param message string
function add_message_into_global_chat_logs(nickname, message)
	if #message > 2000 then return end
	if not settings.global.SChat_allow_log_global_chat.value then return end

	message = "[" .. ticks_to_time(game.tick) .. "] " .. nickname .. ": " .. message
	local global_chat_logs = chat_logs.global
	local last_logs = global_chat_logs[#global_chat_logs]
	if #last_logs > 2000 then
		global_chat_logs[#global_chat_logs+1] = message
	elseif #last_logs == 0 then
		global_chat_logs[#global_chat_logs] = message
	else
		global_chat_logs[#global_chat_logs] = last_logs .. "\n" .. message
	end
end


---@param player LuaPlayer
function switch_chat_logs_frame(player)
	local screen = player.gui.screen
	local main_frame = screen.SChat_chat_logs_frame
	if main_frame then
		main_frame.destroy()
		return
	end

	main_frame = screen.add{
		type = "frame",
		name = "SChat_chat_logs_frame",
		direction = "vertical"
	}
	main_frame.auto_center = true

	local top_flow = main_frame.add(FLOW)
	top_flow.add{
		type = "label",
		style = "frame_title",
		caption = "Global chat logs", --TODO: add and change localization
		ignored_by_interaction = true
	}
	local drag_handler = top_flow.add{type = "empty-widget", style = "draggable_space"}
	drag_handler.drag_target = main_frame
	drag_handler.style.right_margin = 0
	drag_handler.style.horizontally_stretchable = true
	drag_handler.style.height = 32
	top_flow.add(CLOSE_BUTTON)

	local scroll_pane = main_frame.add{
		type = "scroll-pane",
		name = "SChat_scroll_pane"
	}
	local textbox = scroll_pane.add{
		type = "text-box",
		name = "SChat_chat_logs_textbox"
	}
	textbox.read_only = true
	textbox.word_wrap = true
	textbox.style.minimal_height = 250
	textbox.style.maximal_width  = player.display_resolution.width  * 0.6 / player.display_scale
	textbox.style.maximal_height = player.display_resolution.height * 0.6 / player.display_scale
	textbox.style.width  = player.display_resolution.width  * 0.6 / player.display_scale
	textbox.style.height = player.display_resolution.height * 0.6 / player.display_scale
	textbox.style.horizontally_stretchable = true
	textbox.style.vertically_stretchable = true
	textbox.text = chat_logs.global[#chat_logs.global]

	local bottom_flow = main_frame.add{type = "flow", direction = "horizontal", style = "dialog_buttons_horizontal_flow"}
	local pusher = bottom_flow.add{type = "empty-widget", style = "draggable_space"}
	pusher.style.horizontally_stretchable = true
	pusher.style.vertically_stretchable = true
	pusher.drag_target = main_frame
	local prev_page_elem = bottom_flow.add{
		type = "button",
		name = "SChat_log_chat_prev_page",
		caption = "<"
	}
	prev_page_elem.style.width = 30
	if #chat_logs.global <= 1 then
		prev_page_elem.enabled = false
	end
	local page_elem = bottom_flow.add{
		type = "textfield",
		name = "SChat_chat_logs_page",
		numeric = true
	}
	page_elem.text = tostring(#chat_logs.global)
	page_elem.style.width = 50
	page_elem.style.vertically_stretchable = false
	local next_page_elem = bottom_flow.add{
		type = "button",
		name = "SChat_log_chat_next_page",
		caption = ">"
	}
	next_page_elem.enabled = false
	next_page_elem.style.width = 30
	pusher = bottom_flow.add{type = "empty-widget", style = "draggable_space"}
	pusher.style.horizontally_stretchable = true
	pusher.style.vertically_stretchable = true
	pusher.drag_target = main_frame
end


local function clicked_chat_gui(event, player, player_index)
	-- Validation of data
	local element = event.element
	local parent = element.parent
	if parent == nil then return end
	if parent.parent == nil then return end
	local chat_main_frame = player.gui.screen.chat_main_frame
	if not chat_main_frame then return end

	local table_chat = chat_main_frame.table_chat
	players_data[player_index].autohide = MAX_AUTOHIDE_TIME

	--TODO: refactor
	if parent.name == "icons" and parent.parent and parent.parent.name == "top_chat" then
		table_chat.notices.visible = false
		table_chat.notices.main.caption = ""
		if element.name == "settings" then
			if event.shift then
				local frame = player.gui.center.secondary_chat_settings
				if frame then
					frame.destroy()
				else
					create_settings_for_everything(player)
				end
			elseif event.alt then
				chat_main_frame.visible = false
				players_data[player_index].settings.main.state_chat.state = false
				script.raise_event(chat_events.on_hide_gui_chat, {player_index = player_index, container = table_chat})
			else
				toggle_settings_chat_gui(player, table_chat)
			end
		elseif element.name == "color" then
			color_picker.create_gui(player)
		end
	elseif element.name == "toogle" and parent.parent.parent and parent.parent.parent.parent.name == "secondary_chat_settings" then
		toogle_visible_list(element, player)
	elseif parent.name == "container" and parent.parent.parent and parent.parent.parent.name == "list" then
		click_list_settings(element.name, player, parent.parent.parent.parent.parent.scroll.settings)
	elseif element.name == "SChat_close" then
		parent.parent.destroy()
	elseif element.name == "SChat_log_chat_prev_page" then
		local page_elem = parent.SChat_chat_logs_page
		local page = tonumber(page_elem.text)
		if page == 1 then
			element.enabled = false
			page_elem.text = "1"
			return
		else
			parent.SChat_log_chat_next_page.enabled = true
			page = page - 1
			element.enabled = (page ~= 1)
			page_elem.text = tostring(page)
			local chat_logs_textbox = parent.parent.SChat_scroll_pane.SChat_chat_logs_textbox
			chat_logs_textbox.text = chat_logs.global[page]
		end
	elseif element.name == "SChat_log_chat_next_page" then
		local page_elem = parent.SChat_chat_logs_page
		local page = tonumber(page_elem.text)
		if page == #chat_logs.global then
			element.enabled = false
			page_elem.text = tostring(chat_logs.global)
			return
		else
			parent.SChat_log_chat_prev_page.enabled = true
			page = page + 1
			element.enabled = (page ~= #chat_logs.global)
			page_elem.text = tostring(page)
			local chat_logs_textbox = parent.parent.SChat_scroll_pane.SChat_chat_logs_textbox
			chat_logs_textbox.text = chat_logs.global[page]
		end
	end
end

local function on_gui_click(event)
	local element = event.element
	if not (element and element.valid) then return end

	local player_index = event.player_index
	if (element.name == "print_in_chat" or match(element.name, "^chat_(.+)")) then
		if event.shift then
			player_send_message(event, true)
		elseif event.control then
			local player = game.get_player(player_index)
			local table_chat = player.gui.screen.chat_main_frame.table_chat
			table_chat.top_chat.chat_table.chat_text_box.text = table_chat.last_messages.last.text
		else
			player_send_message(event)
		end
	else
		local player = game.get_player(player_index)
		local ok, err = pcall(clicked_chat_gui, event, player, player_index)
		if not ok then
			player.print(err, RED_COLOR)
		end
	end
end

local function on_gui_confirmed(event)
	local element = event.element
	if not (element and element.valid) then return end
	if element.name ~= "SChat_chat_logs_page" then return end

	local page = tonumber(element.text)
	if page == nil or page <= 0 then
		page = 1
		element.text = "1"
	elseif page > #chat_logs.global then
		page = #chat_logs.global
		element.text = tostring(page)
	end

	local chat_logs_textbox = element.parent.parent.SChat_scroll_pane.SChat_chat_logs_textbox
	chat_logs_textbox.text = chat_logs.global[page]
end

M.color_picker_ok_pressed = color_picker.ok_pressed

local function on_player_removed(event)
	local player_index = event.player_index
	script.raise_event(chat_events.on_pre_delete_player_data, {player_index = player_index})

	players_data[player_index] = nil
	mod_data.global.mutes[player_index] = nil

	update_chat_gui()
end

local function on_gui_text_changed(event)
	-- Validation of data
	local element = event.element
	if not (element and element.valid) then return end
	local parent = element.parent
	if parent == nil then return end
	local parent2 = parent.parent
	if parent2 == nil then return end
	local parent3 = parent.parent
	if parent3 == nil then return end

	if element.name ~= 'chat_text_box' and parent3.name ~= 'table_chat' then return end
	if string.byte(element.text, -1) ~= 10 then return end
	if #element.text > 1 then
		element.text = element.text:sub(1, -2)
		event.element = parent3.select_chat.interactions.print_in_chat -- is this okay? TODO: fix a weird bug here
		player_send_message(event)

		-- unfocus for the gui
		local text_box = create_chat_text_box(parent)
		if players_data[event.player_index].settings.main.auto_focus.state then
			text_box.focus()
		end
	else
		-- unfocus for the gui
		create_chat_text_box(parent)
	end
end

local function on_gui_checked_state_changed(event)
	-- Validation of data
	local element = event.element
	if not (element and element.valid) then return end

	local parent = element.parent
	if parent.name == 'config_table' and (parent.parent.parent.name == 'settings' or parent.parent.parent.parent.name == 'settings') then
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
	-- Validation of data
	local element = event.element
	if not (element and element.valid) then return end
	local parent = element.parent
	if parent == nil then return end
	if parent.parent.name ~= 'select_chat' then return end

	if parent.name == 'table_filter' then
		update_chat_and_drop_down(parent.parent.interactions.chat_drop_down, game.get_player(event.player_index))
		return true
	elseif element.name == 'chat_drop_down' then
		update_chat_and_drop_down(element, game.get_player(event.player_index))
		return true
	elseif element.name == 'targets_drop_down' then
		local chat_name = get_chat_name(parent.parent.interactions.chat_drop_down.selected_index)
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

local function on_player_joined_game(event)
	-- Validation of data
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	if players_data[player_index] then
		color_picker.destroy_gui(player)

		-- Remove settings
		local frame = player.gui.center.secondary_chat_settings
		if frame then
			frame.destroy()
		end

		local chat_main_frame = player.gui.screen.chat_main_frame
		local settings = players_data[player_index].settings
		if chat_main_frame then
			chat_main_frame.visible = settings.main.state_chat.state
			chat_main_frame.table_chat.top_chat.icons.color.visible = (mod_data.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker"] ~= nil))
		elseif settings.main.state_chat.state and not mod_data.state_chat then
			create_chat_gui(player)
		end
	else
		update_global_config_player(player)
	end

	update_chat_gui()
end

local function on_player_created(event)
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	if players_data[player_index] == nil then
		update_global_config_player(player)
	end

	if #players_data ~= 0 then return end
	-- Delete previous chat GUI
	for _, _player in pairs(game.players) do
		if _player.valid then
			destroy_chat_gui(_player)
		end
	end
end

local function on_player_left_game(event)
	-- Validation of data
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	color_picker.destroy_gui(player)

	local gui = player.gui

	-- Hide chat
	local chat_main_frame = gui.screen.chat_main_frame
	if chat_main_frame then
		chat_main_frame.visible = false
	end

	-- Remove settings
	local frame = gui.center.secondary_chat_settings
	if frame then
		frame.destroy()
	end

	players_data[player_index].autohide = MAX_AUTOHIDE_TIME
end

-- For soft-mods, scenarios, interfaces (not tested)
M.delete = function(event)
	script.raise_event(chat_events.on_pre_remove_mod)

	remove_commands()
	for _, player in pairs(game.players) do
		if player.valid then
			destroy_chat_gui(player)
			color_picker.destroy_gui(player)
		end
	end
	remote.remove_interface('secondary-chat')
	global.secondary_chat = nil
end

local function on_player_muted(event)
	-- Validation of data
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	-- Mute the player
	mod_data.global.mutes[player_index] = true
end

local function on_player_unmuted(event)
	-- Validation of data
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	-- Unmute the player
	mod_data.global.mutes[player_index] = nil
end


local speech_bubble_data = {
	name = "speech-bubble-no-fade",
	position = {},
	source = nil,
	text = '',
	lifetime = 120
}
local function on_console_command(event)
	local command = event.command
	if command ~= "s" and command ~= "shout" then return end

	local message = event.parameters
	local player_index = event.player_index
	if player_index == nil then
		add_message_into_global_chat_logs("[color=red]server[/color]", message)
		return
	end

	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	local character = player.character
	if not character.valid then
		character = nil
	end
	if character and #message < 2000 and #game.players > 1 then
		local setting_value = settings.global["SChat_show_global_messages_visually"].value
		if setting_value then
			speech_bubble_data.lifetime = 120 + (#message * 1.8)
			speech_bubble_data.position = character.position
			speech_bubble_data.source = character
			speech_bubble_data.text = message
			character.surface.create_entity(speech_bubble_data)
		end
	end
	add_message_into_global_chat_logs(player.name, message)
end

local function on_console_chat(event)
	local player_index = event.player_index
	local message = event.message
	if player_index == nil then
		add_message_into_global_chat_logs("[color=red]server[/color]", message)
		return
	end

	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	local force = player.force
	if #force.players > 1 then return end
	if #game.players <= 1 then return end

	-- Send message to everyone
	local color = player.chat_color
	local tag = player.tag
	if tag ~= '' then tag = ' ' .. tag end
	local form_message = {'', player.name, tag, " (", {"command-output.shout"}, ')', {"colon"}, ' ', event.message}
	local character = player.character
	if not character.valid then
		character = nil
	end
	if character and #message < 2000 then
		local setting_value = settings.global["SChat_show_global_messages_visually"].value
		if setting_value then
			speech_bubble_data.lifetime = 120 + (#message * 1.8)
			speech_bubble_data.position = character.position
			speech_bubble_data.source = character
			speech_bubble_data.text = message
			character.surface.create_entity(speech_bubble_data)
		end
	end
	if #form_message < 5000 then
		game.print(form_message, color)
	end
	add_message_into_global_chat_logs(player.name, message)
end


local function check_settings_frame_size(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	local frame = player.gui.center.secondary_chat_settings
	if not frame then return end

	create_settings_for_everything(player)
end


M.events = {
	[defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
	[defines.events.on_player_display_resolution_changed] = check_settings_frame_size,
	[defines.events.on_gui_checked_state_changed] = on_gui_checked_state_changed,
	[defines.events.on_gui_text_changed] = function(event)
		pcall(on_gui_text_changed, event)
	end,
	[defines.events.on_gui_click] = on_gui_click,
	[defines.events.on_gui_confirmed] = on_gui_confirmed,
	[defines.events.on_player_created] = on_player_created,
	[defines.events.on_player_removed] = on_player_removed,
	[defines.events.on_player_joined_game] = on_player_joined_game,
	[defines.events.on_player_left_game] = on_player_left_game,
	[defines.events.on_player_changed_force] = update_chat_gui,
	[defines.events.on_player_promoted] = on_player_promoted,
	[defines.events.on_player_demoted] = on_player_demoted,
	[defines.events.on_player_muted] = on_player_muted,
	[defines.events.on_player_unmuted] = on_player_unmuted,
	[defines.events.on_forces_merging] = update_chat_gui,
	[defines.events.on_console_command] = on_console_command,
	[defines.events.on_console_chat] = on_console_chat,
}

M.on_nth_tick = {
	-- TODO: Test it
	[60 * 60] = function()
		for player_index, player in pairs(game.connected_players) do
			if player.valid then
				local player_data = players_data[player_index]
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
						player_data.autohide = MAX_AUTOHIDE_TIME
					end
				end
			end
		end
	end
}


local function link_data()
	mod_data = global.secondary_chat
	players_data = mod_data.players
	chat_logs = mod_data.chat_logs
	chats = mod_data.chats
end

function global_init()
	global.secondary_chat = global.secondary_chat or {}
	mod_data = global.secondary_chat

	mod_data.chats = mod_data.chats or {}
	mod_data.players = mod_data.players or {}
	mod_data.state_chat = mod_data.state_chat or true
	mod_data.default = mod_data.default or {}
	mod_data.default.player = mod_data.default.player or {}
	mod_data.default.player.settings = configs.player.get_settings()
	mod_data.settings = mod_data.settings or {}
	mod_data.settings.limit_characters = mod_data.settings.limit_characters or 73 * 14 --1022
	mod_data.commands = mod_data.commands or {}
	mod_data.chat_logs = mod_data.chat_logs or {}
	chat_logs = mod_data.chat_logs
	chat_logs.global = chat_logs.global or {''}

	update_global_config()
	link_data()

	chats = mod_data.chats
	if chats.keys == nil then
		init_chats()
	end

	if game then
		for _, player in pairs( game.players ) do
			if player.valid then
				update_global_config_player(player)
			end
		end
	end
end


M.on_init = function()
	global_init()
	M.on_load()

	if mod_data.state_chat == true then
		add_commands()
	end
end

M.on_load = function()
	link_data()

	if not game then
		if mod_data.state_chat == true then
			add_commands()
		end
	end

	local on_round_start = function()
		if not mod_data.state_chat then return end

		-- Create gui of chat
		for _, player in pairs(game.players) do
			if player.valid then return
				create_chat_gui(player)
			end
		end
	end
	local on_round_end = function()
		if not mod_data.state_chat then return end

		-- Destroy gui of chat
		for _, player in pairs(game.players) do
			if player.valid then return
				destroy_chat_gui(player)
			end
		end
	end

	-- Searching events "on_round_start" and "on_round_end"
	for interface_name, _ in pairs( remote.interfaces ) do
		local function_name = "get_event_name"
		if remote.interfaces[interface_name][function_name] then
			local ID_1 = call(interface_name, function_name, "on_round_start")
			local ID_2 = call(interface_name, function_name, "on_round_end")
			if (type(ID_1) == "number") and (type(ID_2) == "number") then
				if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
					table.insert(M.events, ID_1, on_round_start)
					table.insert(M.events, ID_2, on_round_end)
					-- script.on_event(ID_1, on_round_start)
					-- script.on_event(ID_2, on_round_end)
				end
			end
		end
	end

	local function pick_interface(interfaces)
			for _, name in pairs(interfaces) do
					if remote.interfaces[name] then
							return name
					end
			end

			return nil
	end

	-- Searching event "on_ok_button_clicked" from a mod "color-picker"
	local interface = pick_interface({"color-picker"})
	if interface then
		local ID_1 = call(interface, "on_ok_button_clicked")
		if (type(ID_1) == "number" and script.get_event_handler(ID_1) == nil) then
			table.insert(M.events, ID_1, M.color_picker_ok_pressed)
			-- script.on_event(ID_1, module.color_picker_ok_pressed)
		end
	end
end

M.on_configuration_changed = function(event)
	delete_old_chat()
	update_global_config()

	local mod_changes = event.mod_changes["secondary-chat"]
	if not (mod_changes and mod_changes.old_version) then return end

	for _, player in pairs(game.players) do
		if player.valid then
			update_global_config_player(player)
		end
	end

	local version = tonumber(string.gmatch(mod_changes.old_version, "%d+.%d+")())

	if version < 1.27 then
		mod_data.build = nil
	end
end

M.commands = {
	["open-chat-logs"] = function(cmd)
		switch_chat_logs_frame(game.get_player(cmd.player_index))
	end
}

return M

-- Copyright (C) 2017-2020 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local function check_and_change_visible_table(table)
	local is_visible_elements = false
	for _, child in pairs( table.children ) do
		if child.type == 'table' then
			child.style.left_padding = 10
			if #child.children == 0 then
				child.visible = false
			else
				for _, element in pairs( child.children ) do
					if element.visible ~= false then
						is_visible_elements = true
					end
				end
			end
		end
	end

	table.visible = is_visible_elements
end

function create_settings_chat_of_admin(player, settings)
	local main_table
	if settings.admin then
		main_table = settings.admin
		main_table.clear()
	else
		main_table = settings.add{type = 'table', name = 'admin', column_count = 1}
	end
	main_table.style.left_padding = 10
	main_table.style.top_padding = 5
	main_table.style.bottom_padding = 0
	main_table.style.right_padding = 0
	local label = main_table.add{type = 'label', caption = {'gui-map-generator.advanced-tab-title'}}
	label.style.font = "default-semibold"
	-- TODO: do make events... \/
	-- TODO: do make chat logs!
	-- local logs_table = settings.add{type = 'table', name = 'logs', column_count = 20}
	-- logs_table.add{type = 'label', caption = {''}} -- Pick a log
	-- logs_table.add{type = 'drop-down', name = 'pick_chat_for_log'}
	-- logs_table.add{type = 'button', name = 'log_state'} -- on / off
	-- logs_table.add{type = 'drop-down', name = 'whose'} -- (to all, to server, to admins, custom)
	-- TODO: do make manipulation of player!
	-- local table_players = settings.add{type = 'table', name = 'players', column_count = 20}
	-- table_players.add{type = 'label', caption = {''}} -- Pick a player
	-- table_players.add{type = 'drop-down', name = 'pick_player'}
	-- table_players.add{type = 'button', name = ''}
	-- kick, ban, mute.
	-- TODO: do make manipulation of factions!
	-- local table_factions = settings.add{type = 'table', name = 'factions', column_count = 20}
	-- table_factions.add{type = 'label', caption = {''}} -- Pick a faction
	-- table_factions.add{type = 'drop-down', name = 'pick_faction'}
	-- table_factions.add{type = 'button', name = ''}
	-- sub table (pick player).
	-- TODO: do make manipulation of privilages' groups!
	-- local table_permission_groups = settings.add{type = 'table', name = 'permission_groups', column_count = 20}
	-- table_permission_groups.add{type = 'label', caption = {''}} -- Pick a group
	-- table_permission_groups.add{type = 'drop-down', name = 'pick_table_permission_group'}
	-- table_permission_groups.add{type = 'button', name = ''}
	-- sub table (pick player).
	-- TODO: table - standart global chat settings for player
	-- TODO: table - add chat
	-- TODO: table - pick a char for deleting/changing/getting a information!
	make_config_table(main_table, global.secondary_chat.global.settings.main)

	local config_table = main_table.config_table
	config_table.allow_custom_color_message_boolean.enabled = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker"] ~= nil))
	if not config_table.allow_custom_color_message_boolean.enabled then
		config_table.allow_custom_color_message_boolean.tooltip = {'', {'secondary_chat.connect_mod'}, {'colon'},' "Color picker"'}
	end

	check_and_change_visible_table(main_table)
end

function create_settings_chat_of_player(player, settings, is_fast_menu)
	local main_table
	if settings.player then
		main_table = settings.player
		main_table.clear()
	else
		main_table = settings.add{type = 'table', name = 'player', column_count = 1}
	end
	main_table.style.left_padding = 10
	main_table.style.top_padding = 5
	main_table.style.bottom_padding = 0
	main_table.style.right_padding = 0
	local label = main_table.add{type = 'label', caption = {'gui-mod-settings.title'}}
	label.style.font = "default-semibold"
	make_config_table_player(main_table, global.secondary_chat.players[player.index].settings.main, is_fast_menu)

	check_and_change_visible_table(main_table)
end

function toggle_settings_chat_gui(player, table_chat)
	local settings = table_chat.settings
	if settings.visible or #settings.children > 0 then
		settings.clear()
		settings.visible = false
		table_chat.buttons.visible = true
	else
		settings.visible = true
		table_chat.buttons.visible = false
		local label = settings.add{type = 'label', caption = {'permissions-help.help-list', player.name}}
		label.style.font = "default-bold"
		create_settings_chat_of_player(player, settings, true)
	end
end

function update_checkbox(player, element, parameter)
	global.secondary_chat.players[player.index].autohide = max_autohide_time

	local chat_main_frame = player.gui.screen.chat_main_frame
	local table_chat = chat_main_frame.table_chat
	local container = element.parent.parent
	if container.name == 'player' then
		global.secondary_chat.players[player.index].settings.main[parameter].state = element.state

		if parameter == 'state_chat' then
			local event_name = 'on_hide_gui_chat'
			if element.state then
				event_name = 'on_unhide_gui_chat'
			end

			chat_main_frame.visible = element.state
			table_chat.buttons.visible = not element.state
			table_chat.settings.visible = not element.state
			table_chat.settings.clear()

			destroy_settings_gui(player)

			player.print({'', '/toggle-chat ', {'secondary_chat.toggle', "[WIP]"}}) -- TODO: describe commands
			if script.mod_name ~= 'level' then
				player.print({'secondary_chat.or_use_hotkeys'})
			end

			script.raise_event(chat_events[event_name], {player_index = player.index, container = table_chat})
		elseif parameter == 'drop_down' then
			toggle_drop_down(player)
		end
	elseif container.name == 'admin' then
		global.secondary_chat.global.settings.main[parameter] = element.state

		for _, target in pairs( game.connected_players ) do
			if target.admin then
				if chat_main_frame and chat_main_frame.visible and #chat_main_frame.table_chat.settings.children > 0 then
					chat_main_frame.table_chat.settings.admin.config_table[element.name].state = element.state
				end
			end
		end

		if parameter == 'allow_custom_color_message' then
			for _, target in pairs( game.connected_players ) do
				if chat_main_frame then
					chat_main_frame.table_chat.top_chat.icons.color.visible = element.state
					if element.state == false then color_picker.destroy_gui(player) end
				end
			end
		end
	end

	script.raise_event(chat_events.on_changed_parameter_setting, {player_index = player.index, parameter = element, container = container})
end

function update_allow_fast_show(player, element, parameter)
	global.secondary_chat.players[player.index].autohide = max_autohide_time
	global.secondary_chat.players[player.index].settings.main[parameter].allow_fast_show = element.state

	local container = element.parent.parent
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame and chat_main_frame.table_chat.settings[container.name] then
		local table_chat = chat_main_frame.table_chat
		local gui_settings = table_chat.settings[container.name].config_table
		if #gui_settings.children_names > 0 then
			local element_fast_menu = gui_settings[parameter]
			if element.state then
				if not element_fast_menu then
					add_element_config_fast(global.secondary_chat.players[player.index].settings.main[parameter], gui_settings, parameter)
				end
			elseif element_fast_menu then
				element_fast_menu.destroy()
				gui_settings[parameter .. '_boolean'].destroy()
			end
		end
	end

	script.raise_event(chat_events.on_changed_parameter_setting, {player_index = player.index, parameter = element, container = container})
end

function destroy_settings_gui(player)
	local frame = player.gui.center.secondary_chat_settings
	if not frame then return end
	frame.destroy()
end

function create_settings_for_everything(player)
	local visible = {}
	local text = {}

	local frame = player.gui.center.secondary_chat_settings
	if frame then
		local main_table = frame.main_table
		visible.list = main_table.level_3.selecting.list.visible
		text.notice = main_table.level_2.notice.caption
	end

	destroy_settings_gui(player)

	local center = player.gui.center
	local frame = center.add{type = 'frame', name = 'secondary_chat_settings'}
	frame.style.maximal_width = player.display_resolution.height * 0.7
	frame.style.maximal_height = player.display_resolution.width * 0.7
	-- frame.style.minimal_width = 400

	local main_table = frame.add{type = 'table', name = 'main_table', column_count = 1}
	main_table.style.horizontally_stretchable = true
	main_table.style.vertically_stretchable = true

	local child_table = main_table.add{type = 'table', name = 'level_1', column_count = 1}
	child_table.draw_horizontal_line_after_headers = true
	local label = child_table.add{type = 'label', caption = {'gui-map-generator.advanced-tab-title'}}
	label.style.font = 'default-semibold'

	local child_table = main_table.add{type = 'table', name = 'level_2', column_count = 1}
	local label = child_table.add{type = 'label', name = 'notice'}
	label.caption = text.notice or ''

	local child_table = main_table.add{type = 'table', name = 'level_3', column_count = 2}
	child_table.style.maximal_height = 500
	child_table.style.maximal_width = 1000
	child_table.style.vertically_stretchable = true
	local selecting = child_table.add{type = 'table', name = 'selecting', column_count = 2}
	selecting.draw_vertical_lines = true
	selecting.draw_horizontal_lines = true
	selecting.draw_horizontal_line_after_headers = true
	selecting.style.horizontal_spacing = 5

	local list = selecting.add{type = 'table', name = 'list', column_count = 1}
	list.visible = true
	local label = list.add{type = 'label', caption = {'secondary_chat_settings.list'}}
	label.style.font = 'default-semibold'
	local scroll = list.add{name = "scrollpane", name = 'scroll', type = "scroll-pane"}
	scroll.style.maximal_width = 200
	local list_container = scroll.add{type = 'table', name = 'container', column_count = 1}
	list_container.style.horizontal_spacing = 5
	list_container.visible = visible.list or true
	list_container.style.horizontal_align  = 'left'
	update_list_settings(list_container, player)
	local button = selecting.add{type = 'button', name = 'toogle'}
	button.style.maximal_width = 40
	if list.visible then
		button.caption = '<'
	else
		button.caption = '>'
	end
	button.style.font = 'default-semibold'
	button.style.horizontal_align  = 'left'
	button.style.vertical_align = 'center'
	local scrollpane = child_table.add{name = "scrollpane", name = 'scroll', type = "scroll-pane"}
	scrollpane.style.vertical_align = 'top'
	local settings_table = scrollpane.add{type = 'table', name = 'settings', column_count = 1}

	local patreon_table = main_table.add{type = 'table', name = 'patreon', column_count = 2}
	patreon_table.style.vertical_align = 'bottom'
	patreon_table.style.horizontal_align  = 'right'
	patreon_table.add{type = 'label', caption = {'', 'Patreon', {'colon'}}}
	local text_box = patreon_table.add{type = 'text-box', text = 'https://www.patreon.com/ZwerOxotnik'}
	text_box.style.vertically_stretchable = true
	text_box.style.maximal_width = 800
	text_box.read_only = true

	-- local button = main_table.add{type = 'button', name = 'close', caption = {'gui.close'}}
	-- button.style.horizontal_align  = 'right'
end

function check_settings(player)
	local frame = player.gui.center.secondary_chat_settings
	if frame then
		update_list_settings(frame.main_table.level_3.selecting.list.scroll.container, player)

		local settings = frame.main_table.level_3.scroll.settings
		if settings.children then
			click_list_settings(settings.children_names[1], player, settings)
		end
	end
end

function update_list_settings(container, player)
	container.clear()

	local add = function(container, name, caption)
		caption = caption or {'secondary_chat_settings.' .. name}
		local button = container.add{type = 'button', name = name, caption = caption}
		button.style.font = 'default'
	end

	local buttons = {{name = 'personal', caption = {'gui.character'}}, {name = 'statistics'}, {name = 'faq'}}
	for _, data in pairs( buttons ) do
		add(container, data.name, data.caption)
	end

	local buttons = {{name = 'global'}, {name = 'players', caption = {'gui-browse-games.players'}}}
	if player.admin or game.is_multiplayer() == false then
		for _, data in pairs( buttons ) do
			add(container, data.name, data.caption)
		end
	end

	script.raise_event(chat_events.on_update_gui_list_settings, {player_index = player.index, container = container})
end

local table_setting = {}
table_setting['personal'] = {}
table_setting['statistics'] = {}
table_setting['global'] = {}
table_setting['players'] = {}
table_setting['faq'] = {}
--table_setting['translation'] = {}

table_setting['personal'].update = function(player, table)
	create_settings_chat_of_player(player, table)
end
table_setting['statistics'].update = function(player, table)
	local label = table.add{type = 'label', caption = 'WIP'}
	label.style.font = 'default-semibold'
end
table_setting['global'].update = function(player, table)
	if player.admin or game.is_multiplayer() == false then
		create_settings_chat_of_admin(player, table)
	end
end
table_setting['players'].update = function(player, table)
	local label = table.add{type = 'label', caption = 'WIP'}
	label.style.font = 'default-semibold'
	-- if player.admin or game.is_multiplayer() == false then

	-- end
end
table_setting['faq'].update = function(player, table)
	local faq = table.add{type = 'text-box', text ='WIP https://mods.factorio.com/mod/secondary-chat/discussion/5d8b5ff1afa034000d1274fe'}
	faq.style.vertically_stretchable = true
	faq.read_only = true
	faq.style.maximal_width = 800
	local link = table.add{type = 'text-box', text = 'https://mods.factorio.com/mod/secondary-chat/discussion'}
	link.style.vertically_stretchable = true
	link.style.maximal_width = 800
	link.style.maximal_height = 30
	link.read_only = true
end

function click_list_settings(name, player, table)
	if not table_setting[name] then return false end

	table.clear()

	child_table = table.add{type = 'table', name = name, column_count = 1}
	child_table.style.vertically_stretchable = true
	child_table.style.maximal_width = 800
	table_setting[name].update(player, child_table)
	script.raise_event(chat_events.on_update_gui_container_settings, {player_index = player.index, container = child_table})
end

function toogle_visible_list(gui, player)
	local frame = player.gui.center.secondary_chat_settings
	if not frame then return end

	local list = frame.main_table.level_3.selecting.list
	if list.visible then
		gui.caption = '>'
	else
		gui.caption = '<'
	end

	list.visible = not list.visible
end

function check_settings_frame_size(event)
	local player = game.players[event.player_index]
	if not player then return end
	local frame = player.gui.center.secondary_chat_settings
	if not frame then return end
	create_settings_for_everything(player)
end

-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

function destroy_chat_gui(player)
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		local table_chat = chat_main_frame.table_chat
		if global.secondary_chat.players[player.index] then
			global.secondary_chat.players[player.index].gui.saves.hidden.last_message = table_chat.top_chat.chat_table.chat_text_box.text
		end

		script.raise_event(chat_events.on_pre_delete_gui_chat, {player_index = player.index, container = table_chat})
		table_chat.destroy()
	end
end

function update_chat_gui()
	-- Updating of gui
	for _, player in pairs ( game.connected_players ) do
		local chat_main_frame = player.gui.screen.chat_main_frame
		if chat_main_frame and chat_main_frame.visible then
			local drop_down = chat_main_frame.table_chat.select_chat.interactions.chat_drop_down
			update_chat_and_drop_down(drop_down, player)
		end
	end
end

-- function hide_chat_gui(player)
--   local chat_main_frame = player.gui.screen.chat_main_frame
--   if chat_main_frame then
--     chat_main_frame.visible = false
--     global.secondary_chat.players[player.index].settings.main.state_chat.state = false
--   end
-- end

gui_state = {}
gui_state.keys = {}
gui_state.list = {}
for k, name in pairs( {'all', 'friend', 'neutral', 'enemy', 'specific'} ) do
	gui_state.keys[name] = k
	table.insert(gui_state.list, {'secondary_chat_state.'..name})
end

gui_online = {}
gui_online.keys = {}
gui_online.list = {}
for k, name in pairs( {'all', 'online', 'offline'} ) do
	gui_online.keys[name] = k
	table.insert(gui_online.list, {'secondary_chat.show_'..name})
end

function create_chat_text_box(parent, text)
	local name = 'chat_text_box'

	if parent[name] then
		parent[name].destroy()
	end

	local text_box = parent.add{type = 'text-box', name = name, text = text}
	text_box.style.minimal_width = 250
	text_box.style.maximal_width = 300
	text_box.style.maximal_height = 32

	return text_box
end

function create_chat_gui(player)
	if not global.secondary_chat.players[player.index].settings.main.state_chat.state then return end

	local gui = player.gui.screen
	local last_message = ''
	local notice_text = ''
	local chat_text_box_text = ''
	local index = {}
	local items = {}
	local visible = {}

	if gui.chat_main_frame then
		local table_chat = gui.chat_main_frame.table_chat
		chat_text_box_text = table_chat.top_chat.chat_table.chat_text_box.text
		-- last_messages = table_chat.last_messages.last.text -- ???

		local select_chat = table_chat.select_chat
		if select_chat then
			if select_chat.interactions then
				index.chat = select_chat.interactions.chat_drop_down.selected_index
			end

			local table_filter = select_chat.table_filter
			if table_filter then
				index.state = table_filter.drop_down_state.selected_index
				index.online = table_filter.drop_down_online.selected_index
				visible.drop_down_state = table_filter.drop_down_state.visible
				visible.drop_down_online = table_filter.drop_down_online.visible
			end

			local drop_down = select_chat.interactions.targets_drop_down
			if drop_down and drop_down.visible and #drop_down.items > 1 then
				items.items = drop_down.items
				index.items = drop_down.selected_index
			end

			local notices = table_chat.notices
			if notices then
				notice_text = notices.main.caption
			end
		end
	else
		chat_text_box_text = global.secondary_chat.players[player.index].gui.saves.hidden.last_message or ''
	end

	local is_new = true
	if gui.chat_main_frame then
		local chat_main_frame = gui.chat_main_frame
		global.secondary_chat.players[player.index].gui.saves.hidden.last_message = chat_main_frame.table_chat.top_chat.chat_table.chat_text_box.text
		chat_main_frame.destroy()
		is_new = false
	end

	global.secondary_chat.players[player.index].gui.saves.hidden.last_message = nil

	local chat_main_frame = gui.add{type = 'frame', caption = " ", name = 'chat_main_frame', style = "bordered_frame"}
	chat_main_frame.visible = true
	chat_main_frame.style.maximal_width = 380
	chat_main_frame.style.left_padding = 5
	chat_main_frame.style.top_padding = 5
	chat_main_frame.style.bottom_padding = 2
	chat_main_frame.style.right_padding = 2

	local main_table = chat_main_frame.add{type = 'table', caption = " ", name = 'table_chat', column_count = 1}

	local child_table = main_table.add{type = 'table', name = 'top_chat', column_count = 2}
	child_table.style.horizontally_stretchable = false
	child_table.style.horizontally_squashable = false
	local chat = child_table.add{type = 'table', name = 'chat_table', column_count = 1}
	create_chat_text_box(chat, chat_text_box_text)
	local table = child_table.add{type = 'table', name = 'icons', column_count = 30}
	local button = table.add{type = 'button', name = 'settings', caption = '+'} --⚙
	button.style.maximal_height = 20
	button.style.minimal_height = 20
	button.style.minimal_width = 20
	button.style.maximal_width = 20
	button.style.font = 'default'
	button.style.left_padding = 3
	button.style.top_padding = 0
	button.style.bottom_padding = 5
	button.style.right_padding = 0
	button.tooltip = {
		'', {'gui-control-settings.title'}, {'colon'},
		'\n', {'control-keys.mouse-button-1'}, ' - ', {'gui-mod-settings.title'},
		'\n', 'Shift + ', {'control-keys.mouse-button-1'}, ' - ', {'gui-map-generator.advanced-tab-title'},
		'\n', 'Alt + ', {'control-keys.mouse-button-1'}, ' - ', {'secondary_chat.hide_chat'}
	}
	local button = table.add{type = 'button', name = 'color', caption = '█'}
	button.style.maximal_height = 20
	button.style.minimal_height = 20
	button.style.minimal_width = 20
	button.style.maximal_width = 20
	button.style.font = 'default'
	button.style.horizontal_align  = 'left'
	button.style.left_padding = 1
	button.style.top_padding = 0
	button.style.bottom_padding = 3
	button.style.right_padding = 0
	button.style.font_color = player.chat_color
	button.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker"] ~= nil))

	local child_table = main_table.add{type = 'table', name = 'select_chat', column_count = 2}
	child_table.visible = true
	child_table.add{type = 'label', caption = {'secondary_chat.send_to'}}
	local table_select = child_table.add{type = 'table', name = 'interactions', column_count = 30}
	table_select.style.horizontal_align  = 'left'
	local targets_drop_down = table_select.add{type = 'drop-down', name = 'targets_drop_down', items = items.items or {''}, selected_index = index.items or 1}
	targets_drop_down.visible = (index.items and items.items) or false
	targets_drop_down.style.maximal_width = 120
	local drop_down_chat = table_select.add{type = 'drop-down', name = 'chat_drop_down', items = chats.list, selected_index = index.chat or 1}
	drop_down_chat.style.maximal_width = 120
	local button = table_select.add{type = 'button', name = 'print_in_chat', caption = '➤'}
	button.style.maximal_height = 22
	button.style.minimal_height = 22
	button.style.minimal_width = 24
	button.style.maximal_width = 24
	button.style.font = 'default'
	button.style.left_padding = 0
	button.style.top_padding = 0
	button.style.bottom_padding = 0
	button.style.right_padding = 0
	local label = child_table.add{type = 'label', name ='empty_one', caption = ''}
	label.visible = true
	-- TODO: Change tables
	local table_filter = child_table.add{type = 'table', name = 'table_filter', column_count = 30}
	table_filter.style.horizontal_align  = 'left'
	local drop_down_online = table_filter.add{type = 'drop-down', name = 'drop_down_online', items = gui_online.list, selected_index = index.state or 1}
	drop_down_online.style.maximal_width = 240
	drop_down_online.visible = visible.drop_down_online or false
	drop_down_online.style.horizontal_align  = 'left'
	local drop_down_state = table_filter.add{type = 'drop-down', name = 'drop_down_state', items = gui_state.list, selected_index = index.online or 1}
	drop_down_state.style.maximal_width = 240
	drop_down_state.visible = visible.drop_down_state or false
	drop_down_online.style.horizontal_align  = 'left'

	local child_table = main_table.add{type = 'table', name = 'notices', column_count = 1}
	child_table.style.horizontal_align  = 'left'
	local label = child_table.add{type = 'label', name = 'main'}
	label.style.font = 'default-semibold'
	label.style.font_color = {r = 255, g = 140, b = 0}
	label.caption = notice_text or ''

	local child_table = main_table.add{type = 'table', name = 'last_messages', column_count = 1}
	child_table.style.horizontal_align  = 'left'
	child_table.visible = false
	local textfield = child_table.add{type = 'textfield', name = 'last', text = last_message}
	textfield.style.minimal_width = 250
	textfield.style.maximal_width = chat_main_frame.style.maximal_width - 60
	textfield.style.horizontally_stretchable = false
	textfield.style.horizontal_align  = 'left'

	local child_table = main_table.add{type = 'table', name = 'buttons', column_count = 1}
	child_table.style.horizontal_align  = 'left'
	local child_table = main_table.add{type = 'table', name = 'settings', column_count = 1}
	child_table.style.horizontal_align  = 'left'
	child_table.visible = false

	update_chat_and_drop_down(drop_down_chat, player)

	if is_new then
		script.raise_event(chat_events.on_create_gui_chat, {player_index = player.index, container = main_table})
	else
		script.raise_event(chat_events.on_update_gui_chat, {player_index = player.index, container = main_table})
	end
end

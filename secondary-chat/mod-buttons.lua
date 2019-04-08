-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local function send_message_pressed(event)
	local player = game.players[event.player_index]

	-- Check the visibility of the chat
	local table_chat = player.gui.left.table_chat
	if table_chat then
	local select_chat = table_chat.select_chat
		if table_chat.visible then
			if table_chat.top_chat.chat_table.chat_text_box.text == '' then
				table_chat.top_chat.chat_table.chat_text_box.focus()
			else
				event.element = select_chat.interactions.print_in_chat
				player_send_message(event)
			end
		else
			global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not global.secondary_chat.state_chat then return end
		global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('message-send-to-chat', send_message_pressed)

local function send_locale_pressed(event)
	local player = game.players[event.player_index]

	-- Check the visibility of the chat
	local table_chat = game.players[event.player_index].gui.left.table_chat
	if table_chat then
		if table_chat.visible then
			if table_chat.top_chat.chat_table.chat_text_box.text == '' then
				table_chat.top_chat.chat_table.chat_text_box.focus()
			else
				event.element = table_chat.select_chat.interactions.print_in_chat
				player_send_message(event, true)
			end
		else
			global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not global.secondary_chat.state_chat then return end
		global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('locale-send-to-chat', send_locale_pressed)

local function recover_last_message_from_chat_pressed(event)
	local player = game.players[event.player_index]

	-- Check the visibility of the chat
	local table_chat = game.players[event.player_index].gui.left.table_chat
	if table_chat then
		if table_chat.visible then
			table_chat.top_chat.chat_table.chat_text_box.text = table_chat.last_messages.last.text
		else
			global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not global.secondary_chat.state_chat then return end
		global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('last-message-from-chat', recover_last_message_from_chat_pressed)

local function send_to_private_pressed(event)
	if not chats.keys['private'] then return end -- Return if private chat does not exist

	-- Validation of data
	local player = game.players[event.player_index]
	local entity = player.selected
	if not (entity and entity.valid and (entity.type == 'car' or (entity.type == 'player' and entity.player) or (entity.last_user and entity.last_user.valid and entity.last_user ~= player))) then return end

	-- Check the visibility of the chat
	local table_chat = player.gui.left.table_chat
	if table_chat then
		if table_chat.visible then
			-- temporarily (not working now)
			-- if not (table_chat.top_chat and table_chat.top_chat.chat_table.chat_text_box) then return end
			-- if select_chat.visible == false then
			--   select_chat.visible = true
			-- end
		else
			global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not global.secondary_chat.state_chat then return end
		global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end

	if not (table_chat and table_chat.valid and table_chat.select_chat) then return end
	local select_chat = table_chat.select_chat

	-- Find a recipient
	local targets_drop_down = select_chat.interactions.targets_drop_down
	if entity.last_user then
		targets_drop_down.items = {entity.last_user.name}
	elseif entity.type == 'car' then
		local passenger = entity.get_passenger()
		local driver = entity.get_driver()
		if passenger and driver then
			if driver == player then
				targets_drop_down.items = {passenger.player.name}
			elseif passenger == player then
				targets_drop_down.items = {driver.player.name}
			elseif targets_drop_down.selected_index == chats.keys['private'] and driver == game.players[targets_drop_down.items[targets_drop_down.selected_index]] then
				targets_drop_down.items = {passenger.player.name}
			else
				targets_drop_down.items = {driver.player.name}
			end
		elseif passenger and passenger ~= player then
			targets_drop_down.items = {passenger.player.name}
		elseif driver and driver ~= player then
			targets_drop_down.items = {driver.player.name}
		else
			return
		end
	else --if entity.type == 'player' then
		targets_drop_down.items = {entity.player.name}
	end

	local drop_down_online = select_chat.table_filter.drop_down_online
	local drop_down_state = select_chat.table_filter.drop_down_state
	if game.players[targets_drop_down.items[1]].connected then
		if drop_down_online.selected_index == gui_online.keys['offline'] then
			drop_down_online.selected_index = gui_online.keys['online']
		end
	else
		if drop_down_online.selected_index == gui_online.keys['online'] then
			drop_down_online.selected_index = gui_online.keys['offline']
		end
	end
	drop_down_state.selected_index = gui_state.keys['all']

	-- Select a recipient
	select_chat.interactions.chat_drop_down.selected_index = chats.keys['private']
	targets_drop_down.selected_index = 1
	update_chat_and_drop_down(select_chat.interactions.chat_drop_down, player)
	table_chat.top_chat.chat_table.chat_text_box.focus()
end
script.on_event('send-to-private', send_to_private_pressed)

local function send_to_faction_pressed(event)
	if not chats.keys['faction'] then return end -- Return if faction chat does not exist

	-- Validation of data
	local player = game.players[event.player_index]
	local entity = player.selected
	if not (entity and entity.valid and entity.force and #entity.force.players > 0) then return end
	
	-- Check the visibility of the chat
	local table_chat = player.gui.left.table_chat

	if table_chat then
		if table_chat.visible then
			-- temporarily
			-- if not (table_chat.top_chat and table_chat.top_chat.chat_table.chat_text_box) then return end
			-- if select_chat.visible == false then
			--   select_chat.visible = true
			-- end
		else
			global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not global.secondary_chat.state_chat then return end
		global.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end

	if not (table_chat and table_chat.valid and table_chat.select_chat) then return end
	local select_chat = table_chat.select_chat

	local drop_down_online = select_chat.table_filter.drop_down_online
	local drop_down_state = select_chat.table_filter.drop_down_state
	if #entity.force.connected_players == 0 then
		if drop_down_online.selected_index == gui_online.keys['online'] then
			drop_down_online.selected_index = gui_online.keys['offline']
		end
	else
		if drop_down_online.selected_index == gui_online.keys['offline'] then
			drop_down_online.selected_index = gui_online.keys['online']
		end
	end
	drop_down_state.selected_index = gui_state.keys['all']

	-- Select a recipient
	select_chat.interactions.chat_drop_down.selected_index = chats.keys['faction']
	select_chat.interactions.targets_drop_down.items = {entity.force.name, player.force.name}
	select_chat.interactions.targets_drop_down.selected_index = 1
	update_chat_and_drop_down(select_chat.interactions.chat_drop_down, player)
	table_chat.top_chat.chat_table.chat_text_box.focus()
end
script.on_event('send-to-faction', send_to_faction_pressed)

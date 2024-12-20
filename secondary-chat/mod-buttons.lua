-- Copyright (C) 2017-2023 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local function send_message_pressed(event)
	local player = game.get_player(event.player_index)

	-- Check the chat visibility
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		local table_chat = chat_main_frame.table_chat
		local select_chat = table_chat.select_chat
		if chat_main_frame.visible then
			local chat_text_box = table_chat.top_chat.chat_table.chat_text_box
			if chat_text_box.text == '' then
				chat_text_box.focus()
			else
				event.element = select_chat.interactions.print_in_chat
				player_send_message(event)
			end
		else
			storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not storage.secondary_chat.state_chat then return end
		storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('message-send-to-chat', send_message_pressed)

local function send_locale_pressed(event)
	local player = game.get_player(event.player_index)

	-- Check the chat visibility
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		if chat_main_frame.visible then
			local table_chat = chat_main_frame.table_chat
			local chat_text_box = table_chat.top_chat.chat_table.chat_text_box
			if chat_text_box.text == '' then
				chat_text_box.focus()
			else
				event.element = table_chat.select_chat.interactions.print_in_chat
				player_send_message(event, true)
			end
		else
			storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not storage.secondary_chat.state_chat then return end
		storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('locale-send-to-chat', send_locale_pressed)

local function recover_last_message_from_chat_pressed(event)
	local player = game.get_player(event.player_index)

	-- Check the chat visibility
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		if chat_main_frame.visible then
			local table_chat = chat_main_frame.table_chat
			table_chat.top_chat.chat_table.chat_text_box.text = table_chat.last_messages.last.text
		else
			storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not storage.secondary_chat.state_chat then return end
		storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end
end
script.on_event('last-message-from-chat', recover_last_message_from_chat_pressed)

local function send_to_private_pressed(event)
	if not chats.keys['private'] then return end -- Return if private chat does not exist

	-- Validation of data
	local player = game.get_player(event.player_index)
	local entity = player.selected
	if not (entity and entity.valid and (entity.type == 'car' or (entity.type == 'player' and entity.player) or (entity.last_user and entity.last_user.valid and entity.last_user ~= player))) then return end

	-- Check the chat visibility
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame then
		if chat_main_frame.visible then
			-- local table_chat = chat_main_frame.table_chat
			-- temporarily (not working now)
			-- if not (table_chat.top_chat and table_chat.top_chat.chat_table.chat_text_box) then return end
			-- if select_chat.visible == false then
			--   select_chat.visible = true
			-- end
		else
			storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not storage.secondary_chat.state_chat then return end
		storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end

	if not (chat_main_frame and chat_main_frame.valid and chat_main_frame.table_chat.select_chat) then return end
	local table_chat = chat_main_frame.table_chat
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
			elseif targets_drop_down.selected_index == chats.keys['private'] and driver == game.get_player(targets_drop_down.items[targets_drop_down.selected_index]) then
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
	if game.get_player(targets_drop_down.items[1]).connected then
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
	local player = game.get_player(event.player_index)
	local entity = player.selected
	if not (entity and entity.valid and entity.force and #entity.force.players > 0) then return end

	-- Check the chat visibility
	local chat_main_frame = player.gui.screen.chat_main_frame

	if chat_main_frame then
		if chat_main_frame.visible then
			-- temporarily
			-- local table_chat = chat_main_frame.table_chat
			-- if not (table_chat.top_chat and table_chat.top_chat.chat_table.chat_text_box) then return end
			-- if select_chat.visible == false then
			--   select_chat.visible = true
			-- end
		else
			storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
			create_chat_gui(player)
		end
	else
		if not storage.secondary_chat.state_chat then return end
		storage.secondary_chat.players[event.player_index].settings.main.state_chat.state = true
		create_chat_gui(player)
	end

	-- TODO: recheck
	local table_chat = chat_main_frame.table_chat
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

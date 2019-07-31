-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

data = {}
data.chat = {}

data.chat['all'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message'
	}
}

data.chat['surface'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		get_commands = 'get_commands'
	}
}

data.chat['local'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		get_commands = 'get_commands'
	}
}

data.chat['allies'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		get_commands = 'get_commands'
	}
}

data.chat['admins'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		get_commands = 'get_commands'
	}
}

data.chat['private'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		change_list = 'function_change_list'
	}
}

data.chat['faction'] = {
	interface = {
		name = 'secondary-chat',
		send_message = 'function_send_message',
		change_list = 'function_change_list'
	}
}

get_commands = {}
get_commands['surface'] = {{name = 'surface-send', description = 'secondary_chat.surface-send'}}
get_commands['local'] = {{name = 'l', description = 'secondary_chat.local-send'}, {name = 'local-send', description = 'secondary_chat.local-send'}}
get_commands['allies'] = {{name = 'a', description = 'secondary_chat.allied-send'}, {name = 'allied-send', description = 'secondary_chat.allied-send'}}
get_commands['admins'] = {{name = 'admins-send', description = 'secondary_chat.admins-send'}}

function init_chats()
	chats.list = {}
	chats.keys = {}
	chats.data = {}
	for name, _ in pairs( data.chat ) do
		chats.data[name] = {}
		update_chat(name, data.chat[name])
	end
end

function update_chat(name, main_data)
	chats.data[name] = main_data
	local chat = chats.data[name]
	if not chat then return false end

	local interface = chat.interface

	if not interface or type(interface.name) ~= 'string' or not remote.interfaces[interface.name] then
		chat = nil
		log('error interface: chats[' .. name .. ']')
		return false
	elseif type(interface.send_message) ~= 'string' or not remote.interfaces[interface.name][interface.send_message]
			or type(remote.call(interface.name, interface.send_message, name)) ~= 'function' then
		chat = nil
		log('error interface with send_message: chats[' .. name .. ']')
		return false
	end

	chat.allow_log = chat.allow_log or false
	--chat.is_have_state = chat.is_have_state or false
	--chat.is_have_online = chat.is_have_online or false

	if interface.change_list and (type(interface.change_list) ~= 'string' or type(remote.call(interface.name, interface.change_list, name)) ~= 'function') then
		log('error interface with change_list: chats[' .. name .. ']')
		interface.change_list = nil
	end

	if interface.get_commands and (type(interface.get_commands) ~= 'string' or not remote.interfaces[interface.name][interface.get_commands]
			or type(remote.call(interface.name, interface.get_commands, name)) ~= 'table') then
		log('error interface with get_commands: chats[' .. name .. ']')
		interface.get_commands = nil
	end

	table.insert(chats.list, {'secondary_chat_list.' .. name})
	chats.keys[name] = #chats.list

	script.raise_event(chat_events.on_add_chat, {chat_name = name})

	return true
end

send_message = {}

send_message['all'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	print("0000/00/00 00:00:00 [CHAT] " .. player.name .. " " .. player.tag .. ": " .. input_message)
	return sc_print_in_chat({"", player.name .. " (", {"command-output.shout"}, ")", {"colon"}, " ", input_message}, game, player)
end
send_message['surface'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	local message = {"", player.name .. " (", {"secondary_chat_list.surface"}, ")", {"colon"}, " ", input_message}
	local result = false
	for index, target in pairs ( game.players ) do
		if target.surface == player.surface and index ~= player.index then
			result = true
			sc_print_in_chat(message, target, player)
		end
	end

	if result then
		player.force.print(message, player.chat_color)
		print("0000/00/00 00:00:00 [CHAT] " .. player.name .. " " .. player.tag .. ": " .. input_message)
	else
		local message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"noone-to-reply"}}
		send_notice(message, player)
	end
	return result
end

send_message['faction'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	local drop_down = player.gui.screen.chat_main_frame.table_chat.select_chat.interactions.targets_drop_down
	local message

	if drop_down.visible then
		local target = game.forces[drop_down.items[drop_down.selected_index]]
		if target then
			if target ~= player.force then
				message = {"", player.name .. " | " .. player.force.name, {"colon"}, " ", input_message}
				sc_print_in_chat(message, target, player)
				message = {"", player.name .. "➟" .. target.name, {"colon"}, " ", input_message}
				sc_print_in_chat(message, player.force, player)
			else
				if global.secondary_chat.players[player.index].settings.main.with_tag.state then
					if player.tag ~= '' then
						message = {"", player.name .. " " .. player.tag, {"colon"}, " ", input_message}
						return sc_print_in_chat(message, player.force, player)
					else
						message = {"", player.name, {"colon"}, " ", input_message}
						return sc_print_in_chat(message, player.force, player)
					end
				else
					message = {"", player.name, {"colon"}, " ", input_message}
					return sc_print_in_chat(message, player.force, player)
				end
			end
		else
			message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"multiplayer.no-address", drop_down.items[drop_down.selected_index]}}
			send_notice(message, player)
		end
		return target
	else
		if global.secondary_chat.players[player.index].settings.main.with_tag.state then
			if player.tag ~= "" then
				message = {"", player.name .. " " .. player.tag, {"colon"}, " ", input_message}
				return sc_print_in_chat(message, player.force, player)
			else
				message = {"", player.name, {"colon"}, " ", input_message}
				return sc_print_in_chat(message, player.force, player)
			end
		else
			message = {"", player.name, {"colon"}, " ", input_message}
			return sc_print_in_chat(message, player.force, player)
		end
	end
end

send_message['local'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	local pos_p1 = player.position
	local is_draw = false
	if type(input_message) == "string" and string.len(input_message) <= 130 then
		is_draw = true
	end

	local targets = {}
	for _, near_player in pairs (game.connected_players) do
		if player.surface == near_player.surface then
			local pos_p2 = near_player.position
			if ((pos_p1.x - pos_p2.x)^2 + (pos_p1.y - pos_p2.y)^2)^(0.5) <= 116 then
				sc_print_in_chat({"", player.name .. " (", {"secondary_chat_list.local"}, ")", {"colon"}, " ", input_message}, near_player, player)
				if is_draw then
					table.insert(targets, near_player)
				end
			end
		end
	end

	if is_draw then
		rendering.draw_text({
			text = input_message,
			surface = player.surface,
			target = player.character or player.position,
			target_offset = {0, -2.2},
			color = {1, 1, 1},
			time_to_live = 80 + string.len(input_message),
			-- forces = player.force,
			players = targets,
			-- visible = true,
			alignment = "center",
			scale_with_zoom = true
		})
	end

	return true
end

send_message['allies'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	local message = {"", player.name .. " (", {"secondary_chat_list.allies"}, ")", {"colon"}, " ", input_message}
	local result = false
	for _, force in pairs (game.forces) do
		if #force.players ~= 0 and player.force.get_friend(force) then
			result = true
			sc_print_in_chat(message, force, player)
		end
	end

	if result then
		player.force.print(message, player.chat_color)
	else
		local message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"noone-to-reply"}}
		send_notice(message, player)
	end
	return result
end

send_message['admins'] = function(input_message, player)
	script.raise_event(defines.events.on_console_chat, {player_index = player.index, message = input_message})
	local message

	if player.admin then
		message = {"", player.name .. " (", {"secondary_chat_list.admins"}, ")", {"colon"}, " ", input_message}
	else
		message = {"", player.name .. " (", {"secondary_chat.from_not_admin"}, ")", {"colon"}, " ", input_message}
	end

	local result = false
	for index, admin in pairs (game.players) do
		if admin.admin and index ~= player.index then
			sc_print_in_chat(message, admin, player)
			result = true
		end
	end

	if result then
		message = {"", player.name .. " (", {"secondary_chat_list.admins"}, ")", {"colon"}, " ", input_message}
		sc_print_in_chat(message, player, player)
	else
		if player.admin then
			local message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.sole_administrator"}}
			send_notice(message, player)
		else
			local message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.admins_not_founded"}}
			send_notice(message, player)
		end
	end
	return result
end

send_message['private'] = function(input_message, player)
	local drop_down = player.gui.screen.chat_main_frame.table_chat.select_chat.interactions.targets_drop_down
	local target = nil
	if drop_down.visible then
		target = game.players[drop_down.items[drop_down.selected_index]]
	end

	if target then
		local message = {"", player.name .. " (", {"command-output.whisper"}, ")", {"colon"}, " ", input_message}
		player.print(message)
		target.print(message)
	end
	return target
end

change_list = {}

change_list['private'] = function(gui, target, select_list, last_target, drop_down_online, drop_down_state, table_chat)
	if #game.players < 2 then
		gui.selected_index = 0

		table_chat.notices.main.caption = {'', {'secondary_chat.attention'}, {'colon'}, ' ', {'noone-to-reply'}}

		drop_down_online.visible = false
		drop_down_state.visible = false
		return false
	end

	local list_players = {}
	if gui_online.keys['all'] == drop_down_online.selected_index then
		list_players = game.players
	elseif gui_online.keys['online'] == drop_down_online.selected_index then
		list_players = game.connected_players
	else -- gui_online.keys['offline']
		for _, player in pairs( game.players ) do
			if not player.connected then
				table.insert(list_players, player)
			end
		end
	end

	local check_stance = check_stance[get_name_stance(drop_down_state.selected_index)]
	local items = {}
	local new_selected_index
	last_target = last_target and game.players[last_target]
	local index = 0
	for _, player in pairs( list_players ) do
		if check_stance(target.force, player.force) then
			if target ~= player then
				index = index + 1
				table.insert(items, player.name)
			end
			if not new_selected_index and last_target and last_target == player then
				new_selected_index = index
			end
		end
	end

	if #items > 0 then
		select_list.items = items
		select_list.selected_index = new_selected_index or 1
		drop_down_online.visible = true
		drop_down_state.visible = true
	else
		select_list.items = {''}
		select_list.selected_index = 1
	end
	select_list.visible = true
	drop_down_online.visible = true
	drop_down_state.visible = true
	return true
end

change_list['faction'] = function(gui, target, select_list, last_target, drop_down_online, drop_down_state)
	local is_more_than_2_force = function()
		local count = 0
		for _, force in pairs( game.forces ) do
			if #force.players ~= 0 then
				count = count + 1
				if count > 1 then
					return true
				end
			end
		end
		return false
	end

	if not is_more_than_2_force() then
		if select_list.visible then
			select_list.items = {''}
			select_list.selected_index = 1
			select_list.visible = false
		end
		drop_down_online.visible = false
		drop_down_state.visible = false
		return true
	end

	local list_forces = {}
	if gui_online.keys['all'] == drop_down_online.selected_index then
		list_forces = game.forces
	else
		if gui_online.keys['online'] == drop_down_online.selected_index then
			for name, force in pairs( game.forces ) do
				if #force.connected_players > 0 then
					list_forces[name] = force
				end
			end
		else -- gui_online.keys['offline']
			for name, force in pairs( game.forces ) do
				if #force.connected_players == 0 then
					list_forces[name] = force
				end
			end
		end
	end

	local check_stance = check_stance[get_name_stance(drop_down_state.selected_index)]
	local items = {}
	local new_selected_index
	last_target = last_target and game.forces[last_target]
	local index = 0
	for name, force in pairs( list_forces ) do
		if #force.players > 0 and check_stance(target.force, force) then
			table.insert(items, name)
			index = index + 1
			if new_selected_index == nil then
				if last_target then
					if last_target == force then
						new_selected_index = index
					end
				else
					if target.force == force then
						new_selected_index = index
					end
				end
			end
		end
	end

	if #items > 0 then
		select_list.items = items
		select_list.selected_index = new_selected_index or 1
	else
		select_list.items = {''}
		select_list.selected_index = 1
	end
	select_list.visible = true
	drop_down_online.visible = true
	drop_down_state.visible = true
	return true
end

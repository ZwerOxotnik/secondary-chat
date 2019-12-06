-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

function toggle_drop_down(player)
	if not player.gui.screen.chat_main_frame then
		global.secondary_chat.players[player.index].settings.main.drop_down.state = true
		create_chat_gui(player)
		return
	end

	local table_chat = player.gui.screen.chat_main_frame.table_chat
	local select_chat = table_chat.select_chat
	if select_chat then
		local frame = player.gui.center.secondary_chat_settings
		if frame then
			local settings = frame.main_table.level_3.scroll.settings
			if settings.personal then
				local drop_down = settings.personal.player.config_table.drop_down_boolean
				drop_down.state = not select_chat.visible
			end
		end

		global.secondary_chat.players[player.index].settings.main.drop_down.state = not select_chat.visible
		if table_chat.settings and table_chat.settings.player then
			table_chat.settings.player.config_table.drop_down_boolean.state = not select_chat.visible
		end

		select_chat.visible = not select_chat.visible
	else
		log("not found 'select_chat' for the secondary chat")
	end
end

function toggle_chat(cmd)
	-- Validation of data
	local player = game.players[cmd.player_index]
	if not (player and player.valid) then return end

	if cmd.parameter then
		if player.gui.screen.chat_main_frame then
			local parameter = string.lower(cmd.parameter)
			local index = chats.keys[parameter]
			if index then
				toggle_chat_part(parameter, player)
			elseif parameter == "drop-down" then
				toggle_drop_down(player)
			else
				player.print({"secondary_chat.toggle", "WIP"}) -- TODO: describe commands
			end
		else
			create_chat_gui(player)
		end
	else
		local chat_main_frame = player.gui.screen.chat_main_frame
		if chat_main_frame then
			if chat_main_frame.visible then
				chat_main_frame.visible = false
				script.raise_event(chat_events.on_hide_gui_chat, {player_index = player.index, container = chat_main_frame})
			else
				chat_main_frame.visible = true
				script.raise_event(chat_events.on_unhide_gui_chat, {player_index = player.index, container = chat_main_frame})
			end
			global.secondary_chat.players[player.index].settings.main.state_chat.state = chat_main_frame.visible
		else
			create_chat_gui(player)
			global.secondary_chat.players[player.index].settings.main.state_chat.state = true
		end
	end
end

function remove_command(name)
	return commands.commands[name] and commands.remove_command(name)
end

function remove_commands() -- TODO: change
	for name, bool in pairs( global.secondary_chat.commands ) do
		if bool then
			remove_command(name)
		end
	end
end

function add_command(name, description, func, addit_description)
	if type(func) == "function" then
		if type(description) == "string" and (commands.game_commands[name] == nil and commands.commands[name] == nil) then
			commands.add_command(name, {description, addit_description}, func)
			return true
		else
			log("command '" .. name .. "' is not added for secondary-chat")
		end
	else
		log("Function for '" .. name .. "' is not found for secondary-chat")
	end
end

function add_commands()
	for chat_name, chat in pairs( chats.data ) do
		if chat.interface.get_commands then
			local commands = remote.call(chat.interface.name, chat.interface.get_commands, chat_name)
			for _, data in pairs( commands ) do
				local func = function(cmd)
					local player = game.players[cmd.player_index]
					if not player then return end
					if cmd.parameter ~= nil then
						if not is_allow_message(cmd.parameter, player) then return end
						local chat = chats.data[chat_name]
						local send_in_chat = chat and chat.interface.send_message and remote.call(chat.interface.name, chat.interface.send_message, chat_name)
						send_in_chat(cmd.parameter, player)
					else
						player.print({data.description})
					end
				end
				add_command(data.name, data.description, func)
			end
		end
	end

	local toggle_chat_commands = ""
	for name, _ in pairs( chats.keys ) do
		toggle_chat_commands = toggle_chat_commands .. name .. '/'
	end

	add_command("toggle-chat", "secondary_chat.toggle", toggle_chat, toggle_chat_commands)
end

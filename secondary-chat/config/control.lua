-- Copyright (C) 2017-2022 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

configs = {}
configs.global = require('secondary-chat/config/global')
configs.player = require('secondary-chat/config/player')

function update_global_config_player(player)
	player_index = player.index

	if global.secondary_chat.players[player_index] ~= nil then
		local settings = global.secondary_chat.players[player_index].settings
		if settings then
			for table, child_table in pairs( configs.player.get_settings() ) do
				if settings[table] then
					for name, data in pairs( child_table ) do
						local parameter = settings[table][name]
						if parameter then
							if parameter.state == nil or type(data.state) ~= type(parameter) then
								parameter = data
							end
							if parameter.access == nil then
								parameter.access = data.access or true
							end
						else
							settings[table][name] = data
						end
					end
				else
					settings[table] = child_table
				end
			end
		else
			global.secondary_chat.players[player_index].settings = {}
			local settings = global.secondary_chat.players[player_index].settings
			for table, child_table in pairs( global.secondary_chat.default.player.settings ) do
				settings[table] = {}
				for property_name, parameter in pairs( child_table ) do
					settings[table][property_name] = {}
					for parameter_name, data in pairs( parameter ) do
						settings[table][property_name][parameter_name] = data
					end
				end
			end
		end

		local info = global.secondary_chat.players[player_index].info
		if info then
			for table, child_table in pairs( configs.global.get_info() ) do
				if info[table] then
					for name, data in pairs( child_table ) do
						if info[table][name] == nil or type(data) ~= type(info[table][name]) then
							info[table][name] = data
						end
					end
				else
					info[table] = child_table
				end
			end
		else
			global.secondary_chat.players[player_index].info = configs.global.get_info()
		end
	else
		global.secondary_chat.players[player_index] = {}
		global.secondary_chat.players[player_index].settings = {}

		local settings = global.secondary_chat.players[player_index].settings
		for table, child_table in pairs( global.secondary_chat.default.player.settings ) do
			settings[table] = {}
			for property_name, parameter in pairs( child_table ) do
				settings[table][property_name] = {}
				for parameter_name, data in pairs( parameter ) do
					settings[table][property_name][parameter_name] = data
				end
			end
		end

		global.secondary_chat.players[player_index].info = configs.global.get_info()
	end

	global.secondary_chat.players[player_index].gui = global.secondary_chat.players[player_index].gui or {}
	global.secondary_chat.players[player_index].gui.saves = global.secondary_chat.players[player_index].gui.saves or {}
	global.secondary_chat.players[player_index].gui.saves.hidden = global.secondary_chat.players[player_index].gui.saves.hidden or {}
	global.secondary_chat.players[player_index].autohide = max_autohide_time
	global.secondary_chat.players[player_index].blacklist = global.secondary_chat.players[player_index].blacklist or {}

	if player.connected then
		if not global.secondary_chat.state_chat then return end
		create_chat_gui(player)
	end
end

function update_global_config()
	local settings = global.secondary_chat.default.player.settings
	if settings then
		for table, child_table in pairs( configs.player.get_settings() ) do
			if settings[table] then
				for name, data in pairs( child_table ) do
					local parameter = settings[table][name]
					if parameter then
						if parameter.state == nil or type(data.state) ~= type(parameter) then
							parameter = data
						end
						if parameter.access == nil then
							parameter.access = data.access or true
						end
					else
						settings[table][name] = data
					end
				end
			else
				settings[table] = child_table
			end
		end
	else
		global.secondary_chat.default.player.settings = configs.player.get_settings()
	end

	if global.secondary_chat.global == nil then
		global.secondary_chat.global = {}
		global.secondary_chat.global.settings = configs.global.get_settings()
		global.secondary_chat.global.info = configs.global.get_info()
	else
		local settings = global.secondary_chat.global.settings
		if settings then
			for table, child_table in pairs( configs.global.get_settings() ) do
				if settings[table] then
					for name, data in pairs( child_table ) do
						if settings[table][name] == nil or type(data) ~= type(settings[table][name]) then
							settings[table][name] = data
						end
					end
				else
					settings[table] = child_table
				end
			end
		else
			global.secondary_chat.global.settings = configs.global.get_settings()
		end

		local info = global.secondary_chat.global.info
		if info then
			for key, child_table in pairs( configs.global.get_info() ) do
				if info[key] then
					for name, data in pairs( child_table ) do
						if info[key][name] == nil or type(data) ~= type(parameter) then -- TODO: fix
							info[key][name] = data
						end
					end
				else
					info[key] = child_table
				end
			end
		else
			global.secondary_chat.global.info = configs.global.get_info()
		end
	end

	global.secondary_chat.global.mutes = global.secondary_chat.global.mutes or {}
	global.secondary_chat.global.list = global.secondary_chat.global.list or {}
end

function delete_old_chat()
	for _, player in pairs(game.players) do
		local old_chat = player.gui.left.table_chat
		if old_chat then
			old_chat.destroy()
		end
	end
end

function global_init()
	global.secondary_chat = global.secondary_chat or {}
	if script.mod_name == 'level' then
		global.secondary_chat.build = global.secondary_chat.build or build
	end

	global.secondary_chat.chats = global.secondary_chat.chats or {}
	global.secondary_chat.players = global.secondary_chat.players or {}
	global.secondary_chat.state_chat = global.secondary_chat.state_chat or true
	global.secondary_chat.default = global.secondary_chat.default or {}
	global.secondary_chat.default.player = global.secondary_chat.default.player or {}
	global.secondary_chat.default.player.settings = configs.player.get_settings()
	global.secondary_chat.settings = global.secondary_chat.settings or {}
	global.secondary_chat.settings.limit_characters = global.secondary_chat.settings.limit_characters or 73 * 14 --1022
	global.secondary_chat.commands = global.secondary_chat.commands or {}

	update_global_config()

	chats = global.secondary_chat.chats
	if chats.keys == nil then
		init_chats()
	end

	if game then
		for _, player in pairs( game.players ) do
			update_global_config_player(player)
		end
	end
end

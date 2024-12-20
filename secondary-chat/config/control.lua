-- Copyright (C) 2017-2023 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

configs = {}
configs.global = require('secondary-chat/config/global')
configs.player = require('secondary-chat/config/player')

function update_global_config_player(player)
	player_index = player.index

	if storage.secondary_chat.players[player_index] ~= nil then
		local settings = storage.secondary_chat.players[player_index].settings
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
			storage.secondary_chat.players[player_index].settings = {}
			local settings_data = storage.secondary_chat.players[player_index].settings
			for table, child_table in pairs( storage.secondary_chat.default.player.settings ) do
				settings_data[table] = {}
				for property_name, parameter in pairs( child_table ) do
					settings_data[table][property_name] = {}
					for parameter_name, data in pairs( parameter ) do
						settings_data[table][property_name][parameter_name] = data
					end
				end
			end
		end

		local info = storage.secondary_chat.players[player_index].info
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
			storage.secondary_chat.players[player_index].info = configs.global.get_info()
		end
	else
		storage.secondary_chat.players[player_index] = {
			settings = {}
		}

		local settings_data = storage.secondary_chat.players[player_index].settings
		for table, child_table in pairs( storage.secondary_chat.default.player.settings ) do
			settings_data[table] = {}
			for property_name, parameter in pairs( child_table ) do
				settings_data[table][property_name] = {}
				for parameter_name, data in pairs( parameter ) do
					settings_data[table][property_name][parameter_name] = data
				end
			end
		end

		storage.secondary_chat.players[player_index].info = configs.global.get_info()
	end

	storage.secondary_chat.players[player_index].gui = storage.secondary_chat.players[player_index].gui or {}
	storage.secondary_chat.players[player_index].gui.saves = storage.secondary_chat.players[player_index].gui.saves or {}
	storage.secondary_chat.players[player_index].gui.saves.hidden = storage.secondary_chat.players[player_index].gui.saves.hidden or {}
	storage.secondary_chat.players[player_index].autohide = MAX_AUTOHIDE_TIME
	storage.secondary_chat.players[player_index].blacklist = storage.secondary_chat.players[player_index].blacklist or {}

	if player.connected then
		if not storage.secondary_chat.state_chat then return end
		create_chat_gui(player)
	end
end

function update_global_config()
	local settings = storage.secondary_chat.default.player.settings
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
		storage.secondary_chat.default.player.settings = configs.player.get_settings()
	end

	if storage.secondary_chat.global == nil then
		storage.secondary_chat.global = {}
		storage.secondary_chat.global.settings = configs.global.get_settings()
		storage.secondary_chat.global.info = configs.global.get_info()
	else
		local settings_data = storage.secondary_chat.global.settings
		if settings_data then
			for table, child_table in pairs( configs.global.get_settings() ) do
				if settings_data[table] then
					for name, data in pairs( child_table ) do
						if settings_data[table][name] == nil or type(data) ~= type(settings_data[table][name]) then
							settings_data[table][name] = data
						end
					end
				else
					settings_data[table] = child_table
				end
			end
		else
			storage.secondary_chat.global.settings = configs.global.get_settings()
		end

		local info = storage.secondary_chat.global.info
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
			storage.secondary_chat.global.info = configs.global.get_info()
		end
	end

	storage.secondary_chat.global.mutes = storage.secondary_chat.global.mutes or {}
	storage.secondary_chat.global.list = storage.secondary_chat.global.list or {}
end

function delete_old_chat()
	for _, player in pairs(game.players) do
		local old_chat = player.gui.left.table_chat
		if old_chat then
			old_chat.destroy()
		end
	end
end

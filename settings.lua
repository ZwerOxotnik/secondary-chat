--- Adds settings for commands
if mods["BetterCommands"] then
	local is_ok, better_commands = pcall(require, "__BetterCommands__/BetterCommands/control")
	if is_ok then
		better_commands.COMMAND_PREFIX = "schat_"
		better_commands.create_settings("secondary-chat", "schat_") -- Adds switchable commands
	end
end



local create_bool_setting = ZKSettings.create_bool_setting
create_bool_setting("SChat_allow_log_global_chat", "runtime-global", true)
create_bool_setting("SChat_show_global_messages_visually", "runtime-global", true)

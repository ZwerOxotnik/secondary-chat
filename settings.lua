require("BetterCommands/control"):create_settings() -- Adds switchable commands

data:extend({
	{type = "bool-setting", name = "SChat_allow_log_global_chat", setting_type = "runtime-global", default_value = true},
})
require("BetterCommands/control"):create_settings() -- Adds switchable commands

local create_bool_setting = ZKSettings.create_bool_setting
create_bool_setting("SChat_allow_log_global_chat", "runtime-global", true)
create_bool_setting("SChat_show_global_messages_visually", "runtime-global", true)

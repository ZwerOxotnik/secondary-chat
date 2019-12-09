-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local config = {}

config.get_info = function()
	local settings = {
		main = {}
	}
	return settings
end

-- List of player settings.
--  Parameters (each with its own name):: table:
--    The tables contains:
--      state :: boolean (optional): current state of parameter.
--      access :: boolean (optional): player have access to parameter.
--      allow_fast_show :: boolean (optional): show parameter in fast menu.
--      tooltip :: LocalisedString/boolean/string (optional): tooltip of parameter.
config.get_settings = function()
	local settings = {
		main = {
			state_chat = {state = true, access = true, allow_fast_show = false},
			with_tag = {state = true, access = true, allow_fast_show = true},
			auto_focus = {state = false, access = true, allow_fast_show = true},
			drop_down = {state = true, access = true, allow_fast_show = true}
		},
		hidden = {
			allow_write = {state = true, allow_fast_show = false}
		}
	}
	if script.mod_name ~= 'level' then
		settings.main.auto_hide = {state = false, access = true, allow_fast_show = true, tooltip = true}
	end

	return settings
end

return config

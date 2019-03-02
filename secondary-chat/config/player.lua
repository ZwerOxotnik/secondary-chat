-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local config = {}

config.get_info = function()
	return {
		main = {
			
		}
	}
end

-- List of player settings.
--  Parameters (each with its own name):: table:
--    The tables contains:
--      state :: boolean (optional): current state of parameter.
--      access :: boolean (optional): player have access to parameter.
--      allow_show_fast :: boolean (optional): show parameter in fast menu.
--      tooltip :: LocalisedString/boolean/string (optional): tooltip of parameter.
config.get_settings = function()
	return {
		main = {
			state_chat = {state = true, access = true, allow_show_fast = false},
			with_tag = {state = true, access = true, allow_show_fast = true},
			auto_focus = {state = false, access = true, allow_show_fast = true},
			drop_down = {state = true, access = true, allow_show_fast = true}
		},
		hidden = {
			allow_write = {state = true, allow_show_fast = false}
		}
	}
end

return config

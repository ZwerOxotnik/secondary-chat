-- Copyright (C) 2017-2023 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local config = {}

config.get_info = function()
	return {
		main = {}
	}
end

config.get_settings = function()
	return {
		main = {
			allow_custom_color_message = true
		}
	}
end

return config

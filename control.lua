-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

event_listener = require("__event-listener__/branch-2/stable-version")
local modules = require("modules")

event_listener.add_events(modules)

if script.mod_name ~= 'level' then
	script.on_nth_tick(60 * 60, modules.secondary_chat.custom_events.autohide)
end

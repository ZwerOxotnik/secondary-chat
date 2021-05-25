if script.level.campaign_name then return end

event_listener = require("event_handler")
local modules = {}
modules.secondary_chat = require("secondary-chat/control")

event_listener.add_libraries(modules)

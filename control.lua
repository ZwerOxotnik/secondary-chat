event_listener = require("event_handler")
local modules = {}
modules.secondary_chat = require("secondary-chat/control")

event_listener.add_libraries(modules)

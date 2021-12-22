if script.level.campaign_name then return end

local event_handler = require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
local modules = {}
modules.secondary_chat = require("secondary-chat/control")

event_handler.add_libraries(modules)

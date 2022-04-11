if script.level.campaign_name then return end

---@type table<string, module>
local modules = {
  better_commands = require("BetterCommands/control"),
  secondary_chat = require("secondary-chat/control"),
}

modules.better_commands:handle_custom_commands(modules.secondary_chat) -- adds commands

local event_handler = require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
event_handler.add_libraries(modules)

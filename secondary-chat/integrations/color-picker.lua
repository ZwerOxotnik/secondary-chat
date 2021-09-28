-- Copyright (C) 2017-2021 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

local color_picker = {}

-- TODO: change
local function pick_interface()
	for _, name in pairs( {'color-picker'} ) do
		if remote.interfaces[name] then
			return name
		end
	end

	return nil
end

color_picker.destroy_gui = function(player)
	local container = player.gui.center.sccp_container
	if container then
		container.destroy()
	end
end

color_picker.create_gui = function(player)
	local interface = pick_interface()
	if not interface then return false end

	local center = player.gui.center
	if center.sccp_container then
		-- Already opened. Destroy it.
		center.sccp_container.destroy()
	else
		-- No yet opened. Open it.
		remote.call(interface, 'add_instance',
		{
				parent = center,
				container_name = 'sccp_container',
				title_caption = {'secondary_chat.change_color'},
				color = player.chat_color,
				show_ok_button = true
		})
	end

	return true
end

-- Dismiss the color picker when the OK button is clicked and change chat_color of player.
color_picker.ok_pressed = function(event)
	local container = event.container
	if container.name ~= 'sccp_container' then return false end

	local interface = pick_interface()
	local player = game.get_player(event.player_index)
	local color = remote.call(interface, 'get_color', container)
	player.chat_color = color
	local table_chat = player.gui.screen.chat_main_frame.table_chat
	table_chat.top_chat.icons.color.style.font_color = color
	container.destroy()
	return true
end

return color_picker

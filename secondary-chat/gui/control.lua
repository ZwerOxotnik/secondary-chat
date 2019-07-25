-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

require("secondary-chat/gui/config")
require("secondary-chat/gui/chat")
require("secondary-chat/gui/list-chat")
require("secondary-chat/gui/settings")
require("secondary-chat/gui/buttons")

function click_gui_chat(event)
	-- Validation of data
	local gui = event.element
	local player = game.players[event.player_index]
	local chat_main_frame = player.gui.screen.chat_main_frame
	if not chat_main_frame then return false end

	local table_chat = chat_main_frame.table_chat
	global.secondary_chat.players[player.index].autohide = max_autohide_time

	if gui.parent then
		if gui.parent.name == "icons" and gui.parent.parent.name == "top_chat" then
			table_chat.notices.main.caption = ""
			if gui.name == "settings" then
				if event.shift then
					local frame = player.gui.center.secondary_chat_settings
					if frame then
						frame.destroy()
					else
						create_settings_for_everything(player)
					end
				elseif event.alt then
					chat_main_frame.visible = false
					global.secondary_chat.players[event.player_index].settings.main.state_chat.state = false
					script.raise_event(chat_events.on_hide_gui_chat, {player_index = event.player_index, container = table_chat})
				else
					toggle_settings_chat_gui(player, table_chat)
				end
				return true
			elseif gui.name == "color" then
				color_picker.create_gui(player)
				return true
			end
		elseif gui.name == "toogle" and gui.parent.parent.parent and gui.parent.parent.parent.parent.name == "secondary_chat_settings" then
			toogle_visible_list(gui, player)
			return true
		elseif gui.parent.name == "container" and gui.parent.parent.parent.name == "list" then
			click_list_settings(gui.name, player, gui.parent.parent.parent.parent.parent.scroll.settings)
			return true
		end
	end
end

function player_send_message(event, is_localised)
	local gui = event.element
	local player = game.players[event.player_index]
	local table_chat = player.gui.screen.chat_main_frame.table_chat

	table_chat.notices.main.caption = ""

	local text_box = table_chat.top_chat.chat_table.chat_text_box
	if text_box.text == "" then return false end
	local drop_down = table_chat.select_chat.interactions.chat_drop_down
	local selected_index = (gui.name == "print_in_chat" and gui.parent and gui.parent.parent.name == "select_chat" and drop_down.selected_index)
													or chats.keys[string.match(gui.name, "chat_(.+)")] -- For buttons
	if selected_index then
		if not is_allow_message(text_box.text, player) then return end
		local chat_name = get_chat_name(selected_index)
		local chat = chats.data[chat_name]
		local send_in_chat = chat and remote.call(chat.interface.name, chat.interface.send_message, chat_name)
		if send_in_chat then
			local is_sended = false
			if is_localised then
				is_sended = send_in_chat({text_box.text}, player)
			else
				is_sended = send_in_chat(text_box.text, player)
			end

			if is_sended then
				table_chat.last_messages.last.text = text_box.text

				text_box.text = ""
				if global.secondary_chat.players[event.player_index].settings.main.auto_focus.state then
					text_box.focus()
				end

				script.raise_event(chat_events.on_send_message, {player_index = event.player_index, message = text_box.text, chat = chat_name})

				return true
			end
		else
			if gui.name == "print_in_chat" then
				log("unknown selected_index=" .. selected_index .. " for functions_click_on_chat by " .. player.name)
			else
				log("unknown gui.name=" .. gui.name .. ", selected_index=" .. selected_index .. " for function secondary-chat.click_gui_chat by " .. player.name)
			end
		end
		return
	elseif gui.parent and gui.parent.name == "buttons" then
		log("unknown gui.name=" .. gui.name .. " for function secondary-chat.click_gui_chat in table 'buttons' by " .. player.name)
	end
	return false
end

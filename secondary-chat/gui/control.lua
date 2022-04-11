-- Copyright (C) 2017-2022 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

require("secondary-chat/gui/config")
require("secondary-chat/gui/chat")
require("secondary-chat/gui/list-chat")
require("secondary-chat/gui/settings")
require("secondary-chat/gui/buttons")

function player_send_message(event, is_localised)
	local gui = event.element
	local player = game.get_player(event.player_index)
	local table_chat = player.gui.screen.chat_main_frame.table_chat

	table_chat.notices.visible = false
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

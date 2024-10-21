-- Copyright (C) 2017-2023 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");


local draw_text = rendering.draw_text


function is_allow_message(message, sender)
	if sender then
		if not storage.secondary_chat.players[sender.index].settings.hidden.allow_write.state then
			message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.not_allowed_to_write"}}
			send_notice(message, sender)
		elseif storage.secondary_chat.global.mutes[sender.index] then
			message = {"command-help.mutes"}
			send_notice(message, sender)
		elseif #message < storage.secondary_chat.settings.limit_characters then
			return true
		else
			log({"", sender.name .. " > ", {"secondary_chat.long_message"}})
			message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.long_message"}}
			send_notice(message, sender)
		end
	elseif #message < storage.secondary_chat.settings.limit_characters then
		return true
	end

	return false
end

function sc_print_in_chat(message, receiver, sender)
	-- TODO: blacklist
	receiver.print(message, sender.chat_color)
	return true
end

function is_force_have_allies(target)
	for _, force in pairs (game.forces) do
		if force.valid and #force.players ~= 0 and target.get_friend(force) then
			return true
		end
	end
	return false
end

function check_and_get_chat_number(name)
	if type(chats.keys[name]) == "number" then
		return chats.keys[name]
	else
		log("chat '" .. name .. "' not found for secondary-chat")
		return nil
	end
end

function check_and_get_chat_name(name)
	if type(chats.keys[name]) == "number" then
		return name
	else
		log("chat '" .. name .. "' not found for secondary-chat")
		return nil
	end
end

function get_chat_name(index)
	for name, index_chat in pairs( chats.keys ) do
		if index_chat == index then
			return name
		end
	end
	return nil
end

function get_name_stance(index)
	for name, index_chat in pairs( gui_state.keys ) do
		if index_chat == index then
			return name
		end
	end
	return nil
end

check_stance = {}
check_stance['all'] = function()
	return true
end
check_stance['friend'] = function(force, other_force)
	if force ~= other_force then
		if (force.get_cease_fire(other_force) and other_force.get_cease_fire(force)) and (force.get_friend(other_force) and other_force.get_friend(force)) then
			return true
		end
	else
		return true
	end
	return false
end
check_stance['neutral'] = function(force, other_force)
	if (force.get_cease_fire(other_force) and other_force.get_cease_fire(force)) and (not force.get_friend(other_force) and not other_force.get_friend(force)) then
		return true
	end
	return false
end
check_stance['enemy'] = function(force, other_force)
	if force ~= other_force then
		if (not force.get_cease_fire(other_force) and not other_force.get_cease_fire(force)) and (not force.get_friend(other_force) and not other_force.get_friend(force)) then
			return true
		end
	end
	return false
end
check_stance['specific'] = function(force, other_force)
	if force.get_cease_fire(other_force) ~= other_force.get_cease_fire(force) or force.get_friend(other_force) ~= other_force.get_friend(force) then
		return true
	end
	return false
end

local notice_players = {nil}
local notice_text_data = {
	text = '',
	surface = nil,
	target = nil,
	target_offset = {0, -1.4},
	color = {1, 1, 1},
	time_to_live = 110,
	players = notice_players,
	alignment = "left",
	scale_with_zoom = true
}
function send_notice(message, player)
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame and chat_main_frame.visible then
		local notices = chat_main_frame.table_chat.notices
		notices.visible = true
		notices.main.caption = message
	else
		if player.afk_time < 1800 or type(message) ~= "string" or #message > 60 then
			player.print(message)
		else
			notice_players[1] = player
			notice_text_data.text = message
			notice_text_data.surface = player.surface
			notice_text_data.target = player.character or player.position
			draw_text(notice_text_data)
		end
	end
end

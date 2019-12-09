-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

function is_allow_message(message, sender)
	if sender then
		if not global.secondary_chat.players[sender.index].settings.hidden.allow_write.state then
			message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.not_allowed_to_write"}}
			send_notice(message, sender)
		elseif global.secondary_chat.global.mutes[sender.index] then
			message = {"command-help.mutes"}
			send_notice(message, sender)
		elseif string.len(message) < global.secondary_chat.settings.limit_characters then
			return true
		else
			log({"", sender.name .. " > ", {"secondary_chat.long_message"}})
			message = {"", {"secondary_chat.attention"}, {"colon"}, " ", {"secondary_chat.long_message"}}
			send_notice(message, sender)
		end
	elseif string.len(message) < global.secondary_chat.settings.limit_characters then
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
		if #force.players ~= 0 and target.get_friend(force) then
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

function send_notice(message, player)
	local chat_main_frame = player.gui.screen.chat_main_frame
	if chat_main_frame and chat_main_frame.visible then
		local notice = chat_main_frame.table_chat.notices.main
		notice.caption = message
	else
		if player.afk_time < 1800 or type(message) ~= "string" or string.len(message) > 60 then
			player.print(message)
		else
			rendering.draw_text({
				text = message,
				surface = player.surface,
				target = player.character or player.position,
				target_offset = {0, -1.4},
				color = {1, 1, 1},
				time_to_live = 110,
				players = {player},
				alignment = "left",
				scale_with_zoom = true
			})
		end
	end
end

-- Copyright (C) 2017-2020 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

function update_chat_and_drop_down(gui, target)
	global.secondary_chat.players[target.index].autohide = max_autohide_time

	local select_list = gui.parent.targets_drop_down
	local interactions_table = gui.parent.parent
	local table_chat = interactions_table.parent
	local drop_down_online = interactions_table.table_filter.drop_down_online
	local drop_down_state = interactions_table.table_filter.drop_down_state
	local chat_name = get_chat_name(gui.selected_index)
	local chat = chats.data[chat_name]
	local change_list = chat and chat.interface.change_list and remote.call(chat.interface.name, chat.interface.change_list, chat_name)
	if change_list then
		local last_target = #select_list.items > 1 and select_list.items[select_list.selected_index]
		local result = change_list(gui, target, select_list, last_target, drop_down_online, drop_down_state, table_chat)
		script.raise_event(chat_events.on_update_chat_and_drop_down, {player_index = target.index, chat_name = get_chat_name(gui.selected_index), target = select_list.items[select_list.selected_index]})
		return result
	elseif select_list.visible then
		select_list.selected_index = 1
		select_list.visible = false
		select_list.items = {''}
		drop_down_online.visible = false
		drop_down_state.visible = false
		script.raise_event(chat_events.on_update_chat_and_drop_down, {player_index = target.index, chat_name = chat_name})
		return nil
	end

end

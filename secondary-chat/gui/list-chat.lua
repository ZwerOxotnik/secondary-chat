function update_chat_and_drop_down(gui, target)
  global.secondary_chat.players[target.index].autohide = max_time_autohide
  local select_list = gui.parent.select_drop_down
  local select_chat = gui.parent.parent
  local drop_down_online = select_chat.table_filter.drop_down_online
  local drop_down_state = select_chat.table_filter.drop_down_state
  local chat_name = get_name_chat(gui.selected_index)
  local change_list = chats.data[chat_name] and chats.data[chat_name].gui.change_list
  if change_list then
    local last_target = #select_list.items > 1 and select_list.items[select_list.selected_index]
    return change_list(gui, target, select_list, last_target, drop_down_online, drop_down_state)
  elseif select_list.style.visible then
    select_list.selected_index = 1
    select_list.style.visible = false
    select_list.items = {''}
    drop_down_online.style.visible = false
    drop_down_state.style.visible = false
    return nil
  end
end

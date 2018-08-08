function update_chat_and_drop_down(gui, target)
  local select_list = gui.parent.select_drop_down
  local chat_name = get_name_chat(gui.selected_index)
  log(chat_name)
  local change_list = chats.data[chat_name] and chats.data[chat_name].gui.change_list
  if change_list then
    local last_target = #select_list.items > 1 and select_list.items[select_list.selected_index]
    return change_list(gui, target, select_list, last_target)
  elseif select_list.style.visible then
    select_list.selected_index = 1
    select_list.style.visible = false
    select_list.items = {''}
    return false
  end
  return false
end

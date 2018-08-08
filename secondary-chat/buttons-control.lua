local function send_message_pressed(event)
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and (table_chat.style.visible or table_chat.style.visible == nil) and table_chat.select_chat and table_chat.select_chat.table.print_in_chat and table_chat.top.chat_text_box) then return end

  if table_chat.top.chat_text_box.text == '' then
    table_chat.top.chat_text_box.focus()
  else
    event.element = table_chat.select_chat.table.print_in_chat
    click_gui_chat(event)
  end
end
script.on_event('message-send-to-chat', send_message_pressed)

local function send_locale_pressed(event)
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and (table_chat.style.visible or table_chat.style.visible == nil) and table_chat.select_chat and table_chat.select_chat.table.print_in_chat and table_chat.top.chat_text_box) then return end

  if table_chat.top.chat_text_box.text == '' then
    table_chat.top.chat_text_box.focus()
  else
    event.element = table_chat.select_chat.table.print_in_chat
    click_gui_chat(event, true)
  end
end
script.on_event('locale-send-to-chat', send_locale_pressed)

local function recove_last_message_from_chat_pressed(event)
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and (table_chat.style.visible or table_chat.style.visible == nil) and table_chat.select_chat and table_chat.select_chat.table.print_in_chat and table_chat.top.chat_text_box) then return end
  table_chat.top.chat_text_box.text = table_chat.last_messages.last.text
end
script.on_event('last-message-from-chat', recove_last_message_from_chat_pressed)
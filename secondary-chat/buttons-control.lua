local function send_message_pressed(event)
  -- Check the visibility of the chat
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and table_chat.style.visible ~= false and table_chat.top and table_chat.top.chat_text_box) then return end

  if table_chat.top.chat_text_box.text == '' then
    table_chat.top.chat_text_box.focus()
  else
    event.element = table_chat.select_chat.table.print_in_chat
    click_gui_chat(event) -- Send the message
  end
end
script.on_event('message-send-to-chat', send_message_pressed)

local function send_locale_pressed(event)
  -- Check the visibility of the chat
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and table_chat.style.visible ~= false and table_chat.top and table_chat.top.chat_text_box) then return end

  if table_chat.top.chat_text_box.text == '' then
    table_chat.top.chat_text_box.focus()
  else
    event.element = table_chat.select_chat.table.print_in_chat
    click_gui_chat(event, true) -- Send the message
  end
end
script.on_event('locale-send-to-chat', send_locale_pressed)

local function recove_last_message_from_chat_pressed(event)
  -- Check the visibility of the chat
  local table_chat = game.players[event.player_index].gui.left.table_chat
  if not (table_chat and table_chat.style.visible ~= false and table_chat.top and table_chat.top.chat_text_box) then return end

  table_chat.top.chat_text_box.text = table_chat.last_messages.last.text
end
script.on_event('last-message-from-chat', recove_last_message_from_chat_pressed)

local function send_to_private_pressed(event)
  if not chats.keys['private'] then return end -- Return if private chat does not exist

  -- Validation of data
  local player = game.players[event.player_index]
  local entity = player.selected
  if not (entity and entity.valid and (entity.type == 'car' or (entity.type == 'player' and entity.player) or (entity.last_user and entity.last_user.valid and entity.last_user ~= player))) then return end

  -- Check the visibility of the chat
  local table_chat = player.gui.left.table_chat
  local select_chat = table_chat.select_chat
  if not (table_chat and table_chat.style.visible ~= false and table_chat.top and table_chat.top.chat_text_box and select_chat.style.visible ~= false) then return end

  -- Find a recipient
  local select_drop_down = select_chat.table.select_drop_down
  if entity.last_user then
    select_drop_down.items = {entity.last_user.name}
  elseif entity.type == 'car' then
    local passenger = entity.get_passenger()
    local driver = entity.get_driver()
    if passenger and driver then
      if driver == player then
        select_drop_down.items = {passenger.player.name}
      elseif passenger == player then
        select_drop_down.items = {driver.player.name}
      elseif select_drop_down.selected_index == chats.keys['private'] and driver == game.players[select_drop_down.items[select_drop_down.selected_index]] then
        select_drop_down.items = {passenger.player.name}
      else
        select_drop_down.items = {driver.player.name}
      end
    elseif passenger and passenger ~= player then
      select_drop_down.items = {passenger.player.name}
    elseif driver and driver ~= player then
      select_drop_down.items = {driver.player.name}
    else
      return
    end
  else --if entity.type == 'player' then
    select_drop_down.items = {entity.player.name}
  end

  -- Select a recipient
  select_chat.table.chat_drop_down.selected_index = chats.keys['private']
  select_drop_down.selected_index = 1
  update_chat_and_drop_down(select_chat.table.chat_drop_down, player)
  table_chat.top.chat_text_box.focus()
end
script.on_event('send_to_private', send_to_private_pressed)

local function send_to_faction_pressed(event)
  if not chats.keys['faction'] then return end -- Return if faction chat does not exist

  -- Validation of data
  local player = game.players[event.player_index]
  local entity = player.selected
  if not (entity and entity.valid and entity.force and #entity.force.players > 0) then return end
  
  -- Check the visibility of the chat
  local table_chat = player.gui.left.table_chat
  local select_chat = table_chat.select_chat
  if not (table_chat and table_chat.style.visible ~= false and table_chat.top and table_chat.top.chat_text_box and select_chat.style.visible ~= false) then return end

  -- Select a recipient
  select_chat.table.chat_drop_down.selected_index = chats.keys['faction'] 
  select_chat.table.select_drop_down.items = {entity.force.name}
  select_chat.table.select_drop_down.selected_index = 1
  update_chat_and_drop_down(select_chat.table.chat_drop_down, player)
  table_chat.top.chat_text_box.focus()
end
script.on_event('send_to_faction', send_to_faction_pressed)

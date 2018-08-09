function destroy_chat_gui(player)
  local table_chat = player.gui.left.table_chat
  if table_chat then
    table_chat.destroy()
  end
end

function update_chat_gui()
  for _, player in pairs ( game.connected_players ) do
    local table_chat = player.gui.left.table_chat
    if table_chat and table_chat.style.visible then
      create_chat_gui(player)
    end
  end
end

-- function hidden_chat_gui(player)
--   local table_chat = player.gui.left.table_chat
--   if table_chat then
--     table_chat.style.visible = false
--     global.secondary_chat.players[player.index].settings.main.state_chat.state = false
--   end
-- end


gui_state = {}
gui_state.keys = {}
gui_state.list = {}
for k, name in pairs( {'all', 'friend', 'neutral', 'enemy', 'specific'} ) do
  gui_state.keys[name] = k
  table.insert(gui_state.list, {'secondary_chat_state.'..name})
end

gui_online = {}
gui_online.keys = {}
gui_online.list = {}
for k, name in pairs( {'all', 'online', 'offline'} ) do
  gui_online.keys[name] = k
  table.insert(gui_online.list, {'secondary_chat.show_'..name})
end

function create_chat_gui(player)
  if not global.secondary_chat.players[player.index].settings.main.state_chat.state then return end
  local gui = player.gui.left
  local text = ''
  local last_message = ''
  local index = {}
  local items = {}

  if gui.table_chat then
    local table_chat = gui.table_chat
    text = table_chat.top.chat_text_box.text
    last_messages = table_chat.last_messages.last.text
    
    local select_chat = table_chat.select_chat
    index.chat = select_chat.table.chat_drop_down.selected_index
    index.state = select_chat.table_filter.drop_down_state.selected_index
    index.online = select_chat.table_filter.drop_down_online.selected_index

    local drop_down = select_chat.table.select_drop_down
    if drop_down and drop_down.visible and #drop_down.items > 1 then
      items.items = drop_down.items
      index.items = drop_down.selected_index
    end
  end

  destroy_chat_gui(player)
  local main_table = gui.add{type = 'table', name = 'table_chat', column_count = 1}
  main_table.style.maximal_width = 360
  main_table.style.left_padding = 5
  main_table.style.top_padding = 5
  main_table.style.bottom_padding = 2
  main_table.style.right_padding = 2

  local child_table = main_table.add{type = 'table', name = 'top', column_count = 3}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  child_table.style.align = 'left'
  local input = child_table.add{type = 'textfield', name = 'chat_text_box', text = text}
  input.style.minimal_width = 250
  input.style.maximal_width = main_table.style.maximal_width - 60
  input.style.horizontally_stretchable = true
  local button = child_table.add{type = 'button', name = 'settings', caption = '⚙'}
  button.style.maximal_height = 20
  button.style.minimal_height = 20
  button.style.minimal_width = 20
  button.style.maximal_width = 20
  button.style.font = 'default'
  button.style.left_padding = 2
  button.style.top_padding = 0
  button.style.bottom_padding = 0
  button.style.right_padding = 0
  button.tooltip = {"gui-control-settings.title"}
  local button = child_table.add{type = 'button', name = 'color', caption = '█'}
  button.style.maximal_height = 20
  button.style.minimal_height = 20
  button.style.minimal_width = 20
  button.style.maximal_width = 20
  button.style.font = 'default'
  button.style.left_padding = 1
  button.style.top_padding = 0
  button.style.bottom_padding = 3
  button.style.right_padding = 0
  button.style.font_color = player.chat_color
  button.style.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker16"] ~= nil or remote.interfaces["color-picker"] ~= nil)) 
  local child_table = main_table.add{type = 'table', name = 'select_chat', column_count = 2}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  local label = child_table.add{type = 'label', caption = {'secondary_chat.send_to'}}
  local table_select = child_table.add{type = 'table', name = 'table', column_count = 3}
  table_select.style.align = 'left'
  local select_drop_down = table_select.add{type = 'drop-down', name = 'select_drop_down', items = items.items or {''}, selected_index = index.items or 1}
  select_drop_down.style.visible = (index.items and items.items) or false
  select_drop_down.style.maximal_width = 120
  local drop_down = table_select.add{type = 'drop-down', name = 'chat_drop_down', items = chats.list, selected_index = index.chat or 1}
  drop_down.style.maximal_width = 120
  update_chat_and_drop_down(drop_down, player)
  local button = table_select.add{type = 'button', name = 'print_in_chat', caption = '➤'}
  button.style.maximal_height = 22
  button.style.minimal_height = 22
  button.style.minimal_width = 24
  button.style.maximal_width = 24
  button.style.font = 'default'
  button.style.left_padding = 0
  button.style.top_padding = 0
  button.style.bottom_padding = 0
  button.style.right_padding = 0
  button.style.vertical_align = 'center'
  local label = child_table.add{type = 'label', name ='empty_one', caption = ''}
  label.style.visible = true
  local table_filter = child_table.add{type = 'table', name = 'table_filter', column_count = 2}
  table_filter.style.align = 'left'
  local drop_down = table_filter.add{type = 'drop-down', name = 'drop_down_online', items = gui_online.list, selected_index = index.state or 1}
  drop_down.style.maximal_width = 240
  drop_down.style.visible = false
  local drop_down = table_filter.add{type = 'drop-down', name = 'drop_down_state', items = gui_state.list, selected_index = index.online or 1}
  drop_down.style.maximal_width = 240
  drop_down.style.visible = false

  local child_table = main_table.add{type = 'table', name = 'notices', column_count = 1}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  child_table.style.align = 'left'
  child_table.style.visible = false
  local button = child_table.add{type = 'label', name = 'main'}

  local child_table = main_table.add{type = 'table', name = 'last_messages', column_count = 1}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  child_table.style.align = 'left'
  child_table.style.visible = false
  local textfield = child_table.add{type = 'textfield', name = 'last', text = last_message}
  textfield.style.minimal_width = 250
  textfield.style.maximal_width = main_table.style.maximal_width - 60
  textfield.style.horizontally_stretchable = false

  local child_table = main_table.add{type = 'table', name = 'buttons', column_count = 1}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  child_table.style.align = 'left'
  local child_table = main_table.add{type = 'table', name = 'settings', column_count = 1}
  child_table.style.left_padding = 0
  child_table.style.top_padding = 0
  child_table.style.bottom_padding = 0
  child_table.style.right_padding = 0
  child_table.style.align = 'left'
  child_table.style.visible = false
end

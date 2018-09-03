function destroy_chat_gui(player)
  local table_chat = player.gui.left.table_chat
  if table_chat then
    global.secondary_chat.players[player.index].gui.saves.hidden.last_message = table_chat.top_chat.chat_table.chat_text_box.text
    table_chat.destroy()
  end
end

function update_chat_gui()
  -- Updating of gui
  for _, player in pairs ( game.connected_players ) do
    local table_chat = player.gui.left.table_chat
    if table_chat and table_chat.style.visible then
      local drop_down = table_chat.select_chat.table.chat_drop_down
      update_chat_and_drop_down(drop_down, player)
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

function create_chat_text_box(parent, text)
  if parent.chat_text_box then
    parent.chat_text_box.destroy()
  end
  
  local text_box = parent.add{type = 'text-box', name = 'chat_text_box', text = text}
  text_box.style.minimal_width = 250
  text_box.style.maximal_width = 300
  text_box.style.maximal_height = 32
end

function create_chat_gui(player)
  if not global.secondary_chat.players[player.index].settings.main.state_chat.state then return end

  local gui = player.gui.left
  local text = ''
  local last_message = ''
  local notice_text = ''
  local index = {}
  local items = {}
  local visible = {}

  local table_chat = gui.table_chat
  if table_chat then
    text = table_chat.top_chat.chat_table.chat_text_box.text
    last_messages = table_chat.last_messages.last.text
    
    local select_chat = table_chat.select_chat
    if select_chat then
      if select_chat.table then 
        index.chat = select_chat.table.chat_drop_down.selected_index
      end

      local table_filter = select_chat.table_filter
      if table_filter then
        index.state = table_filter.drop_down_state.selected_index
        index.online = table_filter.drop_down_online.selected_index
        visible.drop_down_state = table_filter.drop_down_state.style.visible
        visible.drop_down_online = table_filter.drop_down_online.style.visible
      end

      local drop_down = select_chat.table.select_drop_down
      if drop_down and drop_down.visible and #drop_down.items > 1 then
        items.items = drop_down.items
        index.items = drop_down.selected_index
      end

      local notices = table_chat.notices
      if notices then
        notice_text = notices.main.caption
      end
    end
  else
    text = global.secondary_chat.players[player.index].gui.saves.hidden.last_message or ''
  end

  destroy_chat_gui(player)
  global.secondary_chat.players[player.index].gui.saves.hidden.last_message = nil

  local main_table = gui.add{type = 'table', name = 'table_chat', column_count = 1}
  main_table.style.maximal_width = 380
  main_table.style.left_padding = 5
  main_table.style.top_padding = 5
  main_table.style.bottom_padding = 2
  main_table.style.right_padding = 2
  main_table.style.visible = true

  local child_table = main_table.add{type = 'table', name = 'top_chat', column_count = 2}
  child_table.style.horizontally_stretchable = false
  child_table.style.horizontally_squashable = false
  local chat = child_table.add{type = 'table', name = 'chat_table', column_count = 1}
  create_chat_text_box(chat, text)
  local table = child_table.add{type = 'table', name = 'icons', column_count = 30}
  local button = table.add{type = 'button', name = 'settings', caption = '⚙'}
  button.style.maximal_height = 20
  button.style.minimal_height = 20
  button.style.minimal_width = 20
  button.style.maximal_width = 20
  button.style.font = 'default'
  button.style.left_padding = 1
  button.style.top_padding = 0
  button.style.bottom_padding = 0
  button.style.right_padding = 0
  button.tooltip = 
  {
    '', {'gui-control-settings.title'}, {'colon'},
    '\n', {'controls.mouse-button-1'}, ' - ', {'gui-map-generator.basic-tab-title'},
    '\n', 'Shift + ', {'controls.mouse-button-1'}, ' - ', {'gui-map-generator.advanced-tab-title'}
  }
  local button = table.add{type = 'button', name = 'color', caption = '█'}
  button.style.maximal_height = 20
  button.style.minimal_height = 20
  button.style.minimal_width = 20
  button.style.maximal_width = 20
  button.style.font = 'default'
  button.style.align = 'left'
  button.style.left_padding = 1
  button.style.top_padding = 0
  button.style.bottom_padding = 3
  button.style.right_padding = 0
  button.style.font_color = player.chat_color
  button.style.visible = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker16"] ~= nil or remote.interfaces["color-picker"] ~= nil))

  local child_table = main_table.add{type = 'table', name = 'select_chat', column_count = 2}
  child_table.style.visible = true
  local label = child_table.add{type = 'label', caption = {'secondary_chat.send_to'}}
  local table_select = child_table.add{type = 'table', name = 'table', column_count = 30}
  table_select.style.align = 'left'
  local select_drop_down = table_select.add{type = 'drop-down', name = 'select_drop_down', items = items.items or {''}, selected_index = index.items or 1}
  select_drop_down.style.visible = (index.items and items.items) or false
  select_drop_down.style.maximal_width = 120
  local drop_down_chat = table_select.add{type = 'drop-down', name = 'chat_drop_down', items = chats.list, selected_index = index.chat or 1}
  drop_down_chat.style.maximal_width = 120
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
  local label = child_table.add{type = 'label', name ='empty_one', caption = ''}
  label.style.visible = true
  local table_filter = child_table.add{type = 'table', name = 'table_filter', column_count = 30}
  table_filter.style.align = 'left'
  local drop_down_online = table_filter.add{type = 'drop-down', name = 'drop_down_online', items = gui_online.list, selected_index = index.state or 1}
  drop_down_online.style.maximal_width = 240
  drop_down_online.style.visible = visible.drop_down_online or false
  drop_down_online.style.align = 'left'
  local drop_down_state = table_filter.add{type = 'drop-down', name = 'drop_down_state', items = gui_state.list, selected_index = index.online or 1}
  drop_down_state.style.maximal_width = 240
  drop_down_state.style.visible = visible.drop_down_state or false
  drop_down_online.style.align = 'left'

  local child_table = main_table.add{type = 'table', name = 'notices', column_count = 1}
  child_table.style.align = 'left'
  local label = child_table.add{type = 'label', name = 'main'}
  label.style.font = 'default-semibold'
  label.style.font_color = {r = 255, g = 140, b = 0}
  label.caption = notice_text or ''

  local child_table = main_table.add{type = 'table', name = 'last_messages', column_count = 1}
  child_table.style.align = 'left'
  child_table.style.visible = false
  local textfield = child_table.add{type = 'textfield', name = 'last', text = last_message}
  textfield.style.minimal_width = 250
  textfield.style.maximal_width = main_table.style.maximal_width - 60
  textfield.style.horizontally_stretchable = false
  textfield.style.align = 'left'

  local child_table = main_table.add{type = 'table', name = 'buttons', column_count = 1}
  child_table.style.align = 'left'
  local child_table = main_table.add{type = 'table', name = 'settings', column_count = 1}
  child_table.style.align = 'left'
  child_table.style.visible = false

  update_chat_and_drop_down(drop_down_chat, player)
end

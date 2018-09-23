function toggle_chat_part(name)
  local player = game.player
  local flow = player.gui.left.table_chat.buttons
  local table_name = 'table_' .. name
  local main_table = flow[table_name]
  if main_table then
    main_table.destroy()
  else
    local main_table = flow.add{type = 'table', name = table_name, column_count = 1}
    local table = main_table.add{type = 'table', name = 'main', column_count = 8}
    local button = table.add{type = 'button', name = 'chat_' .. name, caption = {'', {'secondary_chat.send_to'}, ' ', {'secondary_chat_list.' .. name}}}
    button.style.font = 'default'
    button.style.top_padding = 0
    button.style.bottom_padding = 0
  end
end

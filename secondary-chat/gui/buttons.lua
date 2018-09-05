function toggle_chat_part(input_name)
  local player = game.player
  local flow = player.gui.left.table_chat.buttons
  local name_button = 'chat_' .. input_name
  local button = flow[name_button]
  if button then
    button.destroy()
  else
    local button = flow.add{type = 'button', name = name_button, caption = {'', {'secondary_chat.send_to'}, ' ', {'secondary_chat_list.' .. input_name}}}
    button.style.font = 'default'
    button.style.top_padding = 0
    button.style.bottom_padding = 0
  end
end

function sc_change_button_allied(player)
  local table_chat = player.gui.left.table_chat
  if table_chat ~= nil then
    if is_force_have_allies(player.force) then
      if table_chat.chat_allied == nil then
        local button = table_chat.add{type = 'button', name = 'chat_allied', caption = {'gui.chat_allied'}}
        button.style.font = 'default'
        button.style.top_padding = 0
        button.style.bottom_padding = 0
      end
    elseif table_chat.chat_allied ~= nil then
      table_chat.chat_allied.destroy()
    end
  end
end

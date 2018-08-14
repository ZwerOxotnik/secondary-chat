function create_settings_chat_of_admin(player, settings)
  local table
  if settings.admin then
    table = settings.admin
    table.clear()
  else
    table = settings.add{type = 'table', name = 'admin', column_count = 1}
  end
  table.style.left_padding = 10
  table.style.top_padding = 5
  table.style.bottom_padding = 0
  table.style.right_padding = 0
  local label = table.add{type = 'label', caption = {'gui-map-generator.advanced-tab-title'}}
  label.style.font = "default-semibold"
  make_config_table(table, global.secondary_chat.global.settings.main)
  
  local config_table = table.config_table
  config_table.allow_custom_color_message_boolean.enabled = (global.secondary_chat.global.settings.main.allow_custom_color_message and (remote.interfaces["color-picker16"] ~= nil or remote.interfaces["color-picker"] ~= nil))
  if not config_table.allow_custom_color_message_boolean.enabled then
    config_table.allow_custom_color_message_boolean.tooltip = {'secondary_chat.connect_color_mod'}
  end

  local is_visible = false
  for _, child in pairs( table.children ) do
    if child.type == 'table' then
      child.style.left_padding = 10
      if #child.children == 0 then
        child.style.visible = false
      else
        for _, element in pairs( child.children ) do
          if element.visible or element.visible == nil then
            is_visible = true
          end
        end
      end
    end
  end
  table.style.visible = is_visible
end

function create_settings_chat_of_player(player, settings)
  local table
  if settings.player then
    table = settings.player
    table.clear()
  else
    table = settings.add{type = 'table', name = 'player', column_count = 1}
  end
  table.style.left_padding = 10
  table.style.top_padding = 5
  table.style.bottom_padding = 0
  table.style.right_padding = 0
  local label = table.add{type = 'label', caption = {'gui-map-generator.basic-tab-title'}}
  label.style.font = "default-semibold"
  make_config_table_player(table, global.secondary_chat.players[player.index].settings.main)

  local is_visible = false
  for _, child in pairs( table.children ) do
    if child.type == 'table' then
      child.style.left_padding = 10
      if #child.children == 0 then
        child.style.visible = false
      else
        for _, element in pairs( child.children ) do
          if element.visible or element.visible == nil then
            is_visible = true
          end
        end
      end
    end
  end
  table.style.visible = is_visible
end

function toggle_settings_chat_gui(player, table_chat)
  local settings = table_chat.settings
  if #settings.children > 0 then
    settings.clear()
    settings.style.visible = false
    table_chat.buttons.style.visible = true
  else
    settings.style.visible = true
    table_chat.buttons.style.visible = false
    local label = settings.add{type = 'label', caption = {'permissions-help.help-list', player.name}}
    label.style.font = "default-bold"
    create_settings_chat_of_player(player, settings)
    if player.admin or game.is_multiplayer() == false then
      create_settings_chat_of_admin(player, settings)
    end
  end
end

function update_checkbox(player, element, parametr)
  local table_chat = player.gui.left.table_chat
  local parent = element.parent.parent.name
  if parent == 'player' then
    global.secondary_chat.players[player.index].settings.main[parametr].state = element.state
    if parametr == 'state_chat' then
      table_chat.style.visible = element.state
      table_chat.buttons.style.visible = not element.state
      table_chat.settings.style.visible = element.state
      table_chat.settings.clear()
      player.print({'', '/toggle-chat ', {'secondary_chat.toggle', global.toggle_chat_commands}})
    elseif parametr == 'drop_down' then
      toggle_drop_down(player)
    end
  elseif parent == 'admin' then
    global.secondary_chat.global.settings.main[parametr] = element.state
    for _, target in pairs( game.connected_players ) do
      if target.admin then
        local table_chat = target.gui.left.table_chat
        if table_chat and table_chat.style.visible and #table_chat.settings.children > 0 then
          table_chat.settings.admin.config_table[element.name].state = element.state
        end
      end
    end

    if parametr == 'allow_custom_color_message' then
      for _, target in pairs( game.connected_players ) do
        local table_chat = target.gui.left.table_chat
        if table_chat and (table_chat.style.visible or table_chat.style.visible == nil) then
          table_chat.top_chat.color.style.visible = element.state
          if element.state == false then color_picker.destroy_gui(player) end
        end
      end
    end
  end
end

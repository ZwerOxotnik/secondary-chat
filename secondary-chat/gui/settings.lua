local function check_and_change_visible_table(table)
  local is_visible_elements = false
  for _, child in pairs( table.children ) do
    if child.type == 'table' then
      child.style.left_padding = 10
      if #child.children == 0 then
        child.style.visible = false
      else
        for _, element in pairs( child.children ) do
          if element.visible ~= false then
            is_visible_elements = true
          end
        end
      end
    end
  end

  table.style.visible = is_visible_elements
end

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
    config_table.allow_custom_color_message_boolean.tooltip = {'', {'secondary_chat.connect_mod'}, {'colon'},' "Color picker"'}
  end

  check_and_change_visible_table(table)
end

function create_settings_chat_of_player(player, settings, is_fast_menu)
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
  make_config_table_player(table, global.secondary_chat.players[player.index].settings.main, is_fast_menu)

  check_and_change_visible_table(table)
end

function toggle_settings_chat_gui(player, table_chat)
  local settings = table_chat.settings
  if settings.style.visible or #settings.children > 0 then
    settings.clear()
    settings.style.visible = false
    table_chat.buttons.style.visible = true
  else
    settings.style.visible = true
    table_chat.buttons.style.visible = false
    local label = settings.add{type = 'label', caption = {'permissions-help.help-list', player.name}}
    label.style.font = "default-bold"
    create_settings_chat_of_player(player, settings, true)
  end
end

function update_checkbox(player, element, parameter)
  global.secondary_chat.players[player.index].autohide = max_time_autohide

  local table_chat = player.gui.left.table_chat
  local container = element.parent.parent
  if container.name == 'player' then
    global.secondary_chat.players[player.index].settings.main[parameter].state = element.state

    if parameter == 'state_chat' then
      if element.state then
        script.raise_event(chat_events.on_hide_gui_chat, {player_index = player.index, container = table_chat})
        table_chat.style.visible = true
      else
        script.raise_event(chat_events.on_unhide_gui_chat, {player_index = player.index, container = table_chat})
        table_chat.style.visible = false
      end
      table_chat.buttons.style.visible = not element.state
      table_chat.settings.style.visible = element.state
      table_chat.settings.clear()

      player.print({'', '/toggle-chat ', {'secondary_chat.toggle', global.toggle_chat_commands}})
      if script.mod_name ~= 'level' then
        player.print({'secondary_chat.or_use_hotkeys'})
      end
    elseif parameter == 'drop_down' then
      toggle_drop_down(player)
    end
  elseif container.name == 'admin' then
    global.secondary_chat.global.settings.main[parameter] = element.state

    for _, target in pairs( game.connected_players ) do
      if target.admin then
        local table_chat = target.gui.left.table_chat
        if table_chat and table_chat.style.visible and #table_chat.settings.children > 0 then
          table_chat.settings.admin.config_table[element.name].state = element.state
        end
      end
    end

    if parameter == 'allow_custom_color_message' then
      for _, target in pairs( game.connected_players ) do
        local table_chat = target.gui.left.table_chat
        if table_chat then
          table_chat.top_chat.icons.color.style.visible = element.state
          if element.state == false then color_picker.destroy_gui(player) end
        end
      end
    end
  end

  script.raise_event(chat_events.on_changed_parameter_setting, {player_index = player.index, parameter = element, container = container})
end

function update_allow_show_fast(player, element, parameter)
  global.secondary_chat.players[player.index].autohide = max_time_autohide
  global.secondary_chat.players[player.index].settings.main[parameter].allow_show_fast = element.state

  local container = element.parent.parent
  local table_chat = player.gui.left.table_chat
  if table_chat.settings[container.name] then
    local gui_settings = table_chat.settings[container.name].config_table
    if #gui_settings.children_names > 0 then
      local element_fast_menu = gui_settings[parameter]
      if element.state then
        if not element_fast_menu then
          add_element_config_fast(global.secondary_chat.players[player.index].settings.main[parameter], gui_settings, parameter)
        end
      elseif element_fast_menu then
        element_fast_menu.destroy()
        gui_settings[parameter .. '_boolean'].destroy()
      end
    end
  end

  script.raise_event(chat_events.on_changed_parameter_setting, {player_index = player.index, parameter = element, container = container})
end

function destroy_settings_gui(player)
  local frame = player.gui.center.secondary_chat_settings
  if not frame then return end
  frame.destroy()
end

function create_settings_for_everything(player)
  local visible = {}
  local text = {}

  local frame = player.gui.center.secondary_chat_settings
  if frame then
    local main_table = frame.main_table
    visible.list = main_table.level_3.select.list.style.visible
    text.notice = main_table.level_2.notice.caption
  end

  destroy_settings_gui(player)

  local center = player.gui.center
  local frame = center.add{type = 'frame', name = 'secondary_chat_settings'}
  frame.style.maximal_width = player.display_resolution.height * 0.7
  frame.style.maximal_height = player.display_resolution.width * 0.7

  local main_table = frame.add{type = 'table', name = 'main_table', column_count = 1}

  local child_table = main_table.add{type = 'table', name = 'level_1', column_count = 1}
  child_table.draw_horizontal_line_after_headers = true
  local label = child_table.add{type = 'label', caption = {'gui-map-generator.advanced-tab-title'}}
  label.style.font = 'default-semibold'

  local child_table = main_table.add{type = 'table', name = 'level_2', column_count = 1}
  local label = child_table.add{type = 'label', name = 'notice'}
  label.caption = text.notice or ''

  local child_table = main_table.add{type = 'table', name = 'level_3', column_count = 2}
  child_table.style.maximal_height = 500
  child_table.style.maximal_width = 800
  local select = child_table.add{type = 'table', name = 'select', column_count = 2}
  select.draw_vertical_lines = true
  select.draw_horizontal_lines = true
  select.draw_horizontal_line_after_headers = true
  select.style.horizontal_spacing = 5

  local list = select.add{type = 'table', name = 'list', column_count = 1}
  list.style.visible = true
  local label = list.add{type = 'label', caption = {'secondary_chat_settings.list'}}
  label.style.font = 'default-semibold'
  local scroll = list.add{name = "scrollpane", name = 'scroll', type = "scroll-pane"}
  scroll.style.maximal_width = 200
  local list_container = scroll.add{type = 'table', name = 'container', column_count = 1}
  list_container.style.horizontal_spacing = 5
  list_container.style.visible = visible.list or true
  list_container.style.align = 'left'
  update_list_settings(list_container, player)
  local button = select.add{type = 'button', name = 'toogle'}
  if list.style.visible then
    button.caption = '<'
  else
    button.caption = '>'
  end
  button.style.font = 'default-semibold'
  button.style.align = 'left'
  button.style.vertical_align = 'center'
  local scroll = child_table.add{name = "scrollpane", name = 'scroll', type = "scroll-pane"}
  scroll.style.vertical_align = 'top'
  local settings = scroll.add{type = 'table', name = 'settings', column_count = 1}

  local patreon = main_table.add{type = 'table', name = 'patreon', column_count = 2}
  patreon.style.vertical_align = 'bottom'
  patreon.style.align = 'right'
  local label = patreon.add{type = 'label', caption = {'', 'Patreon', {'colon'}}}
  local text = patreon.add{type = 'text-box', text = 'https://www.patreon.com/ZwerOxotnik'}
  text.read_only = true

  -- local button = main_table.add{type = 'button', name = 'close', caption = {'gui.close'}}
  -- button.style.align = 'right'
end

function check_settings(player)
  local frame = player.gui.center.secondary_chat_settings
  if frame then
    update_list_settings(frame.main_table.level_3.select.list.scroll.container, player)

    local settings = frame.main_table.level_3.scroll.settings
    if settings.children then
      click_list_settings(settings.children_names[1], player, settings)
    end
  end
end

function update_list_settings(container, player)
  container.clear()

  local add = function(container, name, caption)
    caption = caption or {'secondary_chat_settings.' .. name}
    local button = container.add{type = 'button', name = name, caption = caption}
    button.style.font = 'default'
  end

  for _, data in pairs( {{name = 'personal', caption = {'gui.character'}}, {name = 'statistics'}} ) do
    add(container, data.name, data.caption)
  end

  if player.admin or game.is_multiplayer() == false then
    for _, data in pairs( {{name = 'global'}, {name = 'players', caption = {'gui-browse-games.players'}}} ) do
      add(container, data.name, data.caption)
    end
  end

  script.raise_event(chat_events.on_update_gui_list_settings, {player_index = player.index, container = container})
end

table_setting = {}
table_setting['personal'] = {}
table_setting['statistics'] = {}
table_setting['global'] = {}
table_setting['players'] = {}
--table_setting['translation'] = {}

table_setting['personal'].update = function(player, table)
  create_settings_chat_of_player(player, table)
end
table_setting['statistics'].update = function(player, table)
  local label = table.add{type = 'label', caption = 'WIP'}
  label.style.font = 'default-semibold'
end
table_setting['global'].update = function(player, table)
  if player.admin or game.is_multiplayer() == false then
    create_settings_chat_of_admin(player, table)
  end
end
table_setting['players'].update = function(player, table)
  local label = table.add{type = 'label', caption = 'WIP'}
  label.style.font = 'default-semibold'
  -- if player.admin or game.is_multiplayer() == false then
    
  -- end
end

function click_list_settings(name, player, table)
  if not table_setting[name] then return false end

  table.clear()

  child_table = table.add{type = 'table', name = name, column_count = 1}
  table_setting[name].update(player, child_table)
  script.raise_event(chat_events.on_update_gui_container_settings, {player_index = player.index, container = child_table})
end

function toogle_visible_list(gui, player)
  local frame = player.gui.center.secondary_chat_settings
  if not frame then return end
  
  local list = frame.main_table.level_3.select.list
  if list.style.visible then
    gui.caption = '>'
  else
    gui.caption = '<'
  end

  list.style.visible = not list.style.visible
end

function check_settings_frame_size(event)
  local player = game.players[event.player_index]
  if not player then return end
  local frame = player.gui.center.secondary_chat_settings
  if not frame then return end
  create_settings_for_everything(player)
end
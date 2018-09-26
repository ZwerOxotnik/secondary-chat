function make_config_table(gui, config)
  local config_table = gui.config_table
  if config_table then
    config_table.clear()
  else
    config_table = gui.add{type = 'table', name = 'config_table', column_count = 2}
    config_table.style.column_alignments[2] = 'right'
  end
  local items = game.item_prototypes
  for k, data in pairs (config) do
    local label = config_table.add{type = 'label', name = k}

    if tonumber(data) then
      local input = config_table.add{type = 'textfield', name = k..'_box'}
      input.text = data
      input.style.maximal_width = 100
    elseif tostring(type(data)) == 'boolean' then
      config_table.add{type = 'checkbox', name = k..'_boolean', state = data}
    else
      local menu = config_table.add{type = 'drop-down', name = k..'_dropdown'}
      local index
      if data.options then
        for j, option in pairs (data.options) do
          if items[option] then
            menu.add_item(items[option].localised_name)
          else
            menu.add_item({option})
          end
          if option == data.selected then index = j end
        end
        menu.selected_index = index or 1
      else
        log('bug >'..data..'< with make_config_table')
        for _, player in pairs (game.connected_players) do
          if player.admin then
            game.print('bug >'..data..'< with make_config_table')
          end
        end
      end
    end

    label.caption = {'', {'secondary_chat.' .. k}, {'colon'}}
  end
end

function make_config_table_player(gui, config, is_fast_menu)
  local config_table = gui.config_table
  if config_table then
    config_table.clear()
  else
    local column_count = 2
    if not is_fast_menu then column_count = 3 end
    config_table = gui.add{type = 'table', name = 'config_table', column_count = column_count}
    config_table.style.column_alignments[column_count] = 'right'
  end

  local items = game.item_prototypes
  for k, data in pairs (config) do
    if data.access and (not is_fast_menu or (is_fast_menu and data.allow_show_fast)) then
      if not is_fast_menu then 
        config_table.add{type = 'checkbox', name = k..'-allow_show_fast', state = data.allow_show_fast}
      end

      local label = config_table.add{type = 'label', name = k}

      if tonumber(data.state) then
        local input = config_table.add{type = 'textfield', name = k..'_box'}
        input.text = data.state
        input.style.maximal_width = 100
      elseif tostring(type(data.state)) == 'boolean' then
        config_table.add{type = 'checkbox', name = k..'_boolean', state = data.state}
      else
        local menu = config_table.add{type = 'drop-down', name = k..'_dropdown'}
        local index
        if data.options then
          for j, option in pairs (data.options) do
            if items[option] then
              menu.add_item(items[option].localised_name)
            else
              menu.add_item({option})
            end
            if option == data.selected then index = j end
          end
          menu.selected_index = index or 1
        else
          log('bug >'..data..'< with make_config_table_player')
          for _, player in pairs (game.connected_players) do
            if player.admin then
              game.print('bug >'..data..'< with make_config_table_player')
            end
          end
        end
      end

      label.caption = {'', {'secondary_chat.' .. k}, {'colon'}}
    end
  end
end

function add_element_config_fast(data, config_table, name)
  local items = game.item_prototypes
  if data.access then
    local label = config_table.add{type = 'label', name = name}

    if tonumber(data.state) then
      local input = config_table.add{type = 'textfield', name = name..'_box'}
      input.text = data.state
      input.style.maximal_width = 100
    elseif tostring(type(data.state)) == 'boolean' then
      config_table.add{type = 'checkbox', name = name..'_boolean', state = data.state}
    else
      local menu = config_table.add{type = 'drop-down', name = name..'_dropdown'}
      local index
      if data.options then
        for j, option in pairs (data.options) do
          if items[option] then
            menu.add_item(items[option].localised_name)
          else
            menu.add_item({option})
          end
          if option == data.selected then index = j end
        end
        menu.selected_index = index or 1
      else
        log('bug >'..data..'< with add_element_config_fast')
        for _, player in pairs (game.connected_players) do
          if player.admin then
            game.print('bug >'..data..'< with add_element_config_fast')
          end
        end
      end
    end

    label.caption = {'', {'secondary_chat.' .. name}, {'colon'}}
  end
end

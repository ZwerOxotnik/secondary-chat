
local color_picker = {}

local function find_interface()
  for _, name in pairs( {'color-picker', 'color-picker16'} ) do
    if remote.interfaces[name] then
      return name
    end
  end
  return nil
end

color_picker.destroy_gui = function(player)
  local container = player.gui.center.secondary_chat_color_picker_container
  if container then
    container.destroy()
  end
end

color_picker.create_gui = function(player)
  local interface = find_interface()
  if not interface then return false end
  local center = player.gui.center
  if center.secondary_chat_color_picker_container then
    -- Already opened. Destroy it.
    center.secondary_chat_color_picker_container.destroy()
  else
    -- No yet opened. Open it.
    local color_picker = remote.call(interface, 'add_instance',
    {
      parent = center,
      container_name = 'secondary_chat_color_picker_container',
      title_caption = {'secondary_chat.change_color'},
      color = player.chat_color,
      show_ok_button = true
    })
  end
  return true
end

-- Dismiss the color picker when the OK button is clicked and change chat_color of player.
color_picker.ok_pressed = function(event)
  local container = event.container
  if container.name ~= 'secondary_chat_color_picker_container' then return false end
  local interface = find_interface()
  local player = game.players[event.player_index]
  local color = remote.call(interface, 'get_color', container)
  player.chat_color = color
  local table_chat = player.gui.left.table_chat
  table_chat.top.color.style.font_color = color
  container.destroy()
  return true
end

return color_picker

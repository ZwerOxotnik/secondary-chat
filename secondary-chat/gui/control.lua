require("secondary-chat/gui/config")
require("secondary-chat/gui/chat")
require("secondary-chat/gui/list-chat")
require("secondary-chat/gui/settings")
require("secondary-chat/gui/buttons")

function click_gui_chat(event, is_localised)
  local gui = event.element
  local player = game.players[event.player_index]
  local table_chat = player.gui.left.table_chat
  if not table_chat then return false end


  global.secondary_chat.players[player.index].autohide = max_time_autohide

  if gui.name == "settings" and gui.parent.parent.name == "table_chat" then
    toggle_settings_chat_gui(player, table_chat)
    return true
  elseif gui.name == "color" and gui.parent.parent.name == "table_chat" then
    color_picker.create_gui(player)
  end

  table_chat.notices.main.caption = ""

  local text_box = table_chat.top_chat.chat_text_box
  if text_box.text == "" then return false end
  local drop_down = table_chat.select_chat.table.chat_drop_down
  local selected_index = (gui.name == "print_in_chat" and gui.parent.parent.name == "select_chat" and drop_down.selected_index)
                          or chats.keys[string.match(gui.name, "chat_(.+)")] -- For buttons
  if selected_index then
    if not is_allow_message(text_box.text, player) then return end
    local chat_name = get_name_chat(selected_index)
    local send_in_chat = chats.data[chat_name] and chats.data[chat_name].send_message
    if send_in_chat then
      local bool
      if is_localised then
        bool = send_in_chat({text_box.text}, player, table_chat)
      else 
        bool = send_in_chat(text_box.text, player, table_chat)
      end

      if bool then
        table_chat.last_messages.last.text = text_box.text
        script.raise_event(chat_events.on_console_chat, {player_index = event.player_index, message = text_box.text, chat = chat_name})
        text_box.text = ""
        if global.secondary_chat.players[event.player_index].settings.main.auto_focus.state then
          text_box.focus()
        end
        return true
      end
    else
      if gui.name == "print_in_chat" then
        log("unknown selected_index=" .. selected_index .. " for functions_click_on_chat by " .. player.name)
      else
        log("unknown gui.name=" .. gui.name .. ", selected_index=" .. selected_index .. " for function secondary-chat.click_gui_chat by " .. player.name)
      end
    end
    return
  elseif gui.parent and gui.parent.name == "buttons" then
    log("unknown gui.name=" .. gui.name .. " for function secondary-chat.click_gui_chat in table 'buttons' by " .. player.name)
  end
  return false
end

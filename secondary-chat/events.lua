chat_events =
{
  -- Called when a player successfully send a message.
  --	Contains:
  --		player_index :: uint: The index of the player who did the change.
  --    message :: string: The chat message.
  --		chat_name :: string: name of chat.
  on_send_message = script.generate_event_name(),

  -- Called when a player successfully poke another player.
  --	Contains:
  --		sender_index :: uint: The index of the player who did the poke.
  --		target_index :: uint: The index of the player who receive the poke.
  --on_poke = script.generate_event_name(),

  -- Called when switching mode of the mod
  --	Contains:
  --		state :: boolean:
  on_toggle = script.generate_event_name(),

  -- Called when delete secondary-chat.
  on_remove_mod = script.generate_event_name(),

  -- Called when update for player GUI of chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the color picker's container.
  --		player_index :: uint: The index of the player for whom the change.
  on_update_gui_chat = script.generate_event_name(),

  -- Called when for player create the gui of chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the chat container.
  --		player_index :: uint: The index of the player for whom the change.
  on_create_gui_chat = script.generate_event_name(),

  -- Called when for player delete the gui of chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the chat container.
  --		player_index :: uint: The index of the player for whom the change.
  on_pre_delete_gui_chat = script.generate_event_name(),

  -- Called when for player hide the gui of chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the chat container.
  --		player_index :: uint: The index of the player for whom the change.
  on_hide_gui_chat = script.generate_event_name(),

  -- Called when for player unhide the gui of chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the chat container.
  --		player_index :: uint: The index of the player for whom the change.
  on_unhide_gui_chat = script.generate_event_name(),

  -- Called when a player create a button for chat.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the button container.
  --		player_index :: uint: The index of the player who did the change.
  on_create_button = script.generate_event_name(),

  -- Called when a player delete a button from chat.
  --  Contains:
  --		container :: LuaGuiElement: The GUI element of the button container.
  --		player_index :: uint: The index of the player who did the change.
  on_pre_delete_button = script.generate_event_name(),

  -- Called when add the chat.
  --  Contains:
  --		chat_name :: string: name of chat
  on_add_chat = script.generate_event_name(),

  -- Called when delete the chat.
  --  Contains:
  --		chat_name :: string: name of chat
  on_delete_chat = script.generate_event_name(),

  -- Called when a parameter of the settings was changed.
  --	Contains:
  --		container :: LuaGuiElement: container of the settings.
  --    parameter :: LuaGuiElement: The GUI element of a parameter of the settings.
  --		player_index :: uint: The index of the player who did the change.
  on_changed_parameter_setting = script.generate_event_name(),

  -- Called when update list of the settings for the player.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the list settings.
  --		player_index :: uint: The index of the player for whom the change.
  on_update_gui_list_settings = script.generate_event_name(),

  -- Called when a player pick a settings from list.
  --	Contains:
  --		container :: LuaGuiElement: The GUI element of the settings container.
  --		player_index :: uint: The index of the player for whom the change.
  on_update_gui_container_settings = script.generate_event_name()
}

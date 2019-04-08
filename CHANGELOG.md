# Changelog

## 2019-04-08

### [v1.21.0][v1.21.0]

- Extended the mod interface
- Bugfixes
- Improved compatibility
- Code refactoring
- Changed the mod interface

## 2019-04-07

### [v1.20.1][v1.20.1]

* Improved compatibility

## 2019-03-31

### [v1.20.0][v1.20.0]

* Fixed sending messages by Enter
* Fixed interactions with filters
* Fixed selecting a recipient by hotkey for the private/faction chat when there is no the chat interface
* Fixed filters for selecting a recipient by hotkey for the faction chat
* Fixed localised messages of the local chat
* Fixed extended settings
* Changed style of the extended interface of settings
* The interface is turned off together with the extended interface of settings.
* Non-interacting stuff are hidden.

## 2019-03-09

### [v1.19.2][v1.19.2]

* Fixed loading a save (but unstable deleting and creating commands in the mod now)

## 2019-03-05

### [v1.19.1][v1.19.1]

* Another dependencies

## 2018-03-03

### [v1.19.0][v1.19.0]

* Added: module «[Event listener](https://gitlab.com/ZwerOxotnik/event-listener)»
* Changed: output of local chat
* Changed: output of notice
* Bugfixes

### [v1.18.0][v1.18.0]

* Updated for Factorio 0.17
* Added: auto focus after send message
* Added: events "on_send_message", "on_toggle", "on_pre_remove_mod", "on_update_gui_chat", "on_create_gui_chat", "on_pre_delete_gui_chat", "on_hide_gui_chat", "on_unhide_gui_chat", "on_create_button", "on_pre_delete_button", "on_add_chat", "on_delete_chat", "on_changed_parameter_setting", "on_update_gui_list_settings", "on_update_gui_container_settings" of the mod
* Added: remote interface "secondary-chat"
* Added: admins chat
* Added: /admins-send \<message\> - Sends a message to admins.
* Added: private chat
* Added: between factions chat
* Added: surface chat
* Added: /surface-send \<message\> - Sends a message all players on your surface.
* Added: filters for chats
* Added: CHANGELOG.md and README.md and CONTRIBUTING.md
* Added: shell scripts for interactions with repository on GitLab
* Added: response on events of scenario PvP
* Added: hotkey for send a message (Default: Y)
* Added: hotkey for send a localised message (Default: SHIFT + Y)
* Added: hotkey for recover a last message (Default: CONTROL + Y)
* Added: hotkey for select a recipient for the private chat (Default: Middle mouse button), point the cursor at an entity
* Added: hotkey for select a recipient for the faction chat (Default: SHIFT + Middle mouse button), point the cursor at an entity
* Added: settings for a chat and for a gui
* Added: saving GUI chat data for a player
* Added: autohide gui for the mod
* Added: notices in gui
* Added: sending message in gui by enter
* Added: Ukrainian localization (localization by HAKER PLAY)
* Added: Spanish localization
* Added: Romanian localization (localization by anonymous#1)
* Added: Italian localization (localization by anonymous#1)
* Added: muting
* Changed: /toggle-chat drop-down
* Changed: style of GUI
* Changed: faction chat
* Changed: improved localization
* Changed: improved compatibility with scenarios, mods, soft-mods, game
* Changed: text field in gui not be cleared if message not be sended
* Changed: title
* Fixed: text in text field disappears when the interface was updated
* Code refactoring (not finished)

## 2018-01-14

### [v1.3.0][v1.3.0]

* Added: New GUI for chat
* Changed: command /toggle-chat [\<all/faction/allied/local/drop-down\>]
* Changed: (**temporary**) When you change the faction, depending on the presence of allies, the button "send to allies" **NOT** changes

## 2018-01-13

### [v1.2.4][v1.2.4]

* Changed: (local chat) Now the speed of the flying text is various from the length of the message

## 2018-01-07

### [v1.2.3][v1.2.3]

* Addded: raise event "on_console_chat"
* Changed: (local chat) If length message < 80 then create "flying text"
* Changed: locale for message in chat
* Fixed: the chat is not closed when using /toggle-chat
* Optimized code

### [v1.2.2][v1.2.2]

* Addded: When you change the faction, depending on the presence of allies, the button "send to allies" changes

### [v1.2.1][v1.2.1]

* Changed: description mod
* Changed: don't open allied chat, if there are no allies
* Fixed: variable "text_box" now local
* Optimized code

## 2018-01-06

### [v1.2.0][v1.2.0]

* Changed: command /toggle-chat [\<all/faction/allied/local\>] - disabled or re-enables your own parts of additional chat.

## 2018-01-04

### v1.1.2

* Added: commands /l \<text\> and /local-send \<text\> - sends a message to the nearest players

### v1.1.1

* Added: new flying text is slower and more time for life

### v1.1.0

* Added: local chat in gui
* Added: command /toggle-chat (disables or re-enables your own chat)

## 2017-12-20

### v1.0.0

* First release for 0.16

[v1.21.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.21.0.zip
[v1.20.1]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.20.1.zip
[v1.20.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.20.0.zip
[v1.19.2]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.19.2.zip
[v1.19.1]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.19.1.zip
[v1.19.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.19.0.zip
[v1.18.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.18.0.zip
[v1.3.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.3.0.zip
[v1.2.4]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.4.zip
[v1.2.3]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.3.zip
[v1.2.2]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.2.zip
[v1.2.1]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.1.zip
[v1.2.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.0.zip

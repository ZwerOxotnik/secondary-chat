## 2018-XX-XX

### v2.0.0 WIP

- Added: auto focus after send message
- Added: events "on_console_chat", "toggle" of the mod
- Added: remote interface "secondary-chat" [**WIP!**]
- Added: admins chat
- Added: /admins-send \<message\> - sends a message to admins.
- Added: private chat
- Added: between factions chat
- Added: surface chat
- Added: /surface-send \<message\> - sends a message all players on your surface.
- Added: filters for a chats
- Added: CHANGELOG.md and README.md and CONTRIBUTING.md
- Added: shell scripts for interactions with repository on GitLab
- Added: response on events of scenario PvP
- Added: hotkey for send a message (Default: Y)
- Added: hotkey for send a localised message (Default: SHIFT + Y)
- Added: hotkey for recover a last message (Default: CONTROL + Y)
- Added: hotkey for select a recipient for the private chat (Default: Middle mouse button), point the cursor at an entity
- Added: hotkey for select a recipient for the faction chat (Default: SHIFT + Middle mouse button), point the cursor at an entity
- Added: settings for chat and for gui
- Added: saving data gui of chat for player
- Added: autohide gui for the mod
- Added: notices in gui
- Added: sending message in gui by enter
- Added: localization in Spanish
- Changed: /toggle-chat drop-down
- Changed: style of GUI
- Changed: faction chat
- Changed: improved localization
- Changed: improved compatibility with scenarios, mods, soft-mods
- Changed: text field in gui not be cleared if message not be sended
- Fixed: text in text field disappears when the interface was updated
- Code refactoring

## 2018-01-14

### [v1.3.0][v1.3.0]

- Added: New GUI for chat
- Changed: command /toggle-chat [\<all/faction/allied/local/drop-down\>]
- Changed: (**temporary**) When you change the faction, depending on the presence of allies, the button "send to allies" **NOT** changes

## 2018-01-13

### [v1.2.4][v1.2.4]

- Changed: (local chat) Now the speed of the flying text is various from the length of the message

## 2018-01-07

### [v1.2.3][v1.2.3]

- Addded: raise event "on_console_chat"
- Changed: (local chat) If length message < 80 then create "flying text"
- Changed: locale for message in chat
- Fixed: the chat is not closed when using /toggle-chat
- Optimized code

### [v1.2.2][v1.2.2]

- Addded: When you change the faction, depending on the presence of allies, the button "send to allies" changes

### [v1.2.1][v1.2.1]

- Changed: description mod
- Changed: don't open allied chat, if there are no allies
- Fixed: variable "text_box" now local
- Optimized code

## 2018-01-06

### [v1.2.0][v1.2.0]

- Changed: command /toggle-chat [\<all/faction/allied/local\>] - disabled or re-enables your own parts of additional chat.

## 2018-01-04

### v1.1.2

- Added: commands /l \<text\> and /local-send \<text\> - sends a message to the nearest players

### v1.1.1

- Added: new flying text is slower and more time for life

### v1.1.0

- Added: local chat in gui
- Added: command /toggle-chat (disables or re-enables your own chat)

## 2017-12-20

### v1.0.0

- first release for 0.16

[v2.0.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_2.0.0.zip
[v1.3.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.3.0.zip
[v1.2.4]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.4.zip
[v1.2.3]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.3.zip
[v1.2.2]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.2.zip
[v1.2.1]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.1.zip
[v1.2.0]: https://mods.factorio.com/api/downloads/data/mods/2332/secondary-chat_1.2.0.zip

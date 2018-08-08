# Secondary chat

This mod was created for the game [Factorio][Factorio] and adds gui of chat, new commands, new types of chat.
Top left appear the new gui with drop-down with filters, that sends your message from the text field to the chat.

## Commands

- /a \<message\> or /allied-send \<message\> - sends a message to the allies.
- /l \<message\> or /local-send \<message\> - sends a message to the nearest players.
- /surface-send \<message\> - sends a message all players on your surface.
- /admins-send \<message\> - sends a message to admins.
- /toggle-chat [\<all/faction/allied/local/surface/admins/drop-down\>] - disabled or re-enables your own parts of additional chat.

## How to open the secondary chat

- variant 1: When the game starts from the character appears.
- variant 2: write to chat "/toggle-chat".

## Hotkeys

| Desription | Hotkey (Default) |
| -------- | ---- |
| send a message   | ENTER   |
| send a localised message   | SHIFT + ENTER   |
| recover a last message   | CONTROL + ENTER   |

## Dependencies

### Optional

- [Color picker 0.16](https://mods.factorio.com/mod/color-picker16) or [Color picker](https://forums.factorio.com/viewtopic.php?f=97&t=30657)

## Bugs and suggestions

Please report any issues or feature requests using the Issue tracker on [GitLab](https://gitlab.com/ZwerOxotnik/secondary-chat/issues) or on [mods.factorio.com](https://mods.factorio.com/mod/secondary-chat/discussion).

## Future Plans

- Remake chat
- Completely alter and add new features
- Integration with other mods and etc.
- Provides API to let other mods accessing

## Where to get the mod

You can either download a zip archive from [mods.factorio.com][homepage] or the [GitLab repository](https://gitlab.com/ZwerOxotnik/secondary-chat/tags).

## Contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

Please see [CHANGELOG.md](CHANGELOG.md).

## Installing

If you have downloaded a zip archive:

- simply place it in your mods directory.

For more information, see [Installing Mods on the Factorio wiki](https://wiki.factorio.com/index.php?title=Installing_Mods).

Alternatively, if you have downloaded the source archive:

- copy the mod directory into your factorio mods directory
- rename the mod directory to secondary-chat_*versionnumber*, where *versionnumber* is the version of the mod that you've downloaded (e.g., 2.0.0)

### Prerequisites

- [Git](https://git-scm.com)
- [jq](https://stedolan.github.io/jq/)

## License

This mod is licensed under the [MIT](https://opensource.org/licenses/MIT). See [LICENSE](LICENSE) for details.

[homepage]: http://mods.factorio.com/mod/secondary-chat
[Factorio]: https://factorio.com/

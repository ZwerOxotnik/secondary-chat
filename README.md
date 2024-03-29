[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/ZwerOxotnik/secondary-chat)
[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/ZwerOxotnik/secondary-chat)
# Chat with advanced interactions

Read this in another language | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Contents

* [Overview](#overview)
* [FAQ](#faq)
    * [How to open the chat?](#open-chat)
    * [Hotkeys](#hotkeys)
    * [Where to get the mod?](#get-mod)
    * [Commands](#commands)
* [Dependencies](#dependencies)
    * [Required](#required)
    * [Optional](#optional)
* [Issues](#issue)
* [Features](#feature)
* [Future plans](#Future-plans)
* [Special thanks](special-thanks)
* [Installing](#installing)
* [License](#license)

## Overview

Adds chat logs, draggable chat, new chat commands, new chat types, new chat interactions (for example: localised messages, storing previous sent message, offline/online players/teams, relationships, filters etc), new hotkeys for chat. Provides customizable chat through mod interface, chat settings.

## FAQ

### <a name="open-chat"></a> How to open the chat?

* variant 1: When your character appears.
* variant 2: Press any hothey of the mod.
* variant 3: Write to chat "/toggle-chat".

### Hotkeys

| Desription | Hotkey (Default) |
| -------- | ---- |
| Send a message   | Y   |
| Send a localised message   | SHIFT + Y   |
| Recover a last message   | CONTROL + Y   |
| Select a recipient for the private chat  | Middle mouse button  |
| Select a recipient for the faction chat  | SHIFT + Middle mouse button   |

### <a name="get-mod"></a> Where to get the mod?

You can either download a zip archive from [mods.factorio.com][homepage] or the [GitLab repository](https://gitlab.com/ZwerOxotnik/secondary-chat/tags).

### Commands

* /a \<message\> or /allied-send \<message\> - sends a message to the allies.
* /l \<message\> or /local-send \<message\> - sends a message to the nearest players.
* /surface-send \<message\> - sends a message to all players on your surface.
* /admins-send \<message\> - sends a message to admins.
* /toggle-chat [\<all/faction/allied/local/surface/admins/drop-down\>] - Disabled or re-enables your own parts of additional chat.
* /open-chat-logs - opens chat logs

## Dependencies

### Required

* [Event listener](https://mods.factorio.com/mod/event-listener)

### Optional

* [Color picker](https://forums.factorio.com/viewtopic.php?f=97&t=30657)

## <a name="issue"></a> Found an Issue?

Please report any issues or a mistake in the documentation, you can help us by
[submitting an issue](https://gitlab.com/ZwerOxotnik/secondary-chat/issues) to our GitLab Repository or on [mods.factorio.com](https://mods.factorio.com/mod/secondary-chat/discussion).

## <a name="feature"></a> Want a Feature?

You can *request* a new feature by [submitting an issue](https://gitlab.com/ZwerOxotnik/secondary-chat/issues) to our GitHub
Repository or on [mods.factorio.com](https://mods.factorio.com/mod/secondary-chat/discussion).

## Future plans

* Remake chat
* Completely alter and add new features
* Integration with other mods and etc.
* Provides API to let other mods accessing
* Extend settings for players, admins
* Add and change new events
* Change chat structure
* Change advanced settings
* Add new localizations
* Add Polish localization
* Add blacklist for players
* Add custom chat logs
* Add custom quick message
* Add settings for chats
* Add profiles
* Add export/import of settings

## Special thanks

* **MeteorSbor** - tester
* **midaw** - tester
* **HAKER PLAY** - translator
* **anonymous#1** - translator
* [XMKTP](https://mods.factorio.com/mod/XMKTP) - Xagros's Mods Korean Translation Project

## Installing

If you have downloaded a zip archive:

* simply place it in your mods directory.

For more information, see [Installing Mods on the Factorio wiki](https://wiki.factorio.com/index.php?title=Installing_Mods).

If you have downloaded the source archive (GitLab):

* copy the mod directory into your factorio mods directory
* rename the mod directory to secondary-chat_*versionnumber*, where *versionnumber* is the version of the mod that you've downloaded (e.g., 1.22.4)

## License

This project is copyright © 2017-2023 ZwerOxotnik \<zweroxotnik@gmail.com\>.

Use of the source code included here is governed by the European Union Public License v. 1.2 only. See the [LICENCE](/LICENCE) file for details.

[homepage]: http://mods.factorio.com/mod/secondary-chat
[Factorio]: https://factorio.com/

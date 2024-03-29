# Чат расширенного взаимодействия

Хотите прочитать на другом языке? | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Содержание

* [Введение](#overview)
* [FAQ](#faq)
    * [Как открыть чат?](#open-chat)
    * [Горячие клавиши](#hotkeys)
    * [Где получить мод?](#get-mod)
    * [Комманды](#commands)
* [Зависимости](#dependencies)
    * [Необходимые](#required)
    * [Необязательные](#optional)
* [Сообщить об ошибки](#issue)
* [Запросить функцию](#feature)
* [Установка](#installing)
* [Особая благодарность](special-thanks)
* [Лицензия](#license)

## <a name="overview"></a> Введение

Добавляет графические интерфейсы чата, новые команды чата, новые типы чата, новые взаимодействия чата (например, локализованные сообщения, хранение предыдущего отправленного сообщения, не в сети/в сети игроки/команды, отношения, фильтры и т.д.), новые горячие клавиши для чата. Предоставляет настраиваемый чат через мод интерфейс, настройки чата.
Слева вверху отображается новый графический интерфейс с выпадающим меню, с фильтрами и другими функциями, которые отправляют ваше сообщение из текстового поля в чат и могут упростить взаимодействие с другими элементами.

## <a name="faq"></a> FAQ (часто задаваемые вопросы)

### <a name="open-chat"></a> Как открыть чат?

* вариант 1: Когда появляется ваш персонаж.
* вариант 2: Нажать любую клавишу мода.
* вариант 3: Написать в чат "/toggle-chat".

### <a name="hotkeys"></a> Горячие клавиши

| Описание | Горячие клавиши (По умолчанию) |
| -------- | ---- |
| Отправить сообщение   | Y   |
| Отправить локализованное сообщение   | SHIFT + Y   |
| Восстановить прошлое сообщение  | CONTROL + Y   |
| Выбрать получателя для фракционного чата  | Средняя клавиша мыши  |
| Выбрать получателя для приватного чата  | SHIFT + Средняя клавиша мыши  |

### <a name="get-mod"></a> Где получить мод?

Вы можете скачать zip архив с [mods.factorio.com][homepage] или с [GitLab репозитория](https://gitlab.com/ZwerOxotnik/secondary-chat/tags).

### <a name="commands"></a> Комманды

* /a \<сообщение\> or /allied-send \<сообщение\> - Послать сообщение союзникам.
* /l \<сообщение\> or /local-send \<сообщение\> - Послать сообщение ближайшим игрокам.
* /surface-send \<сообщение\> - Послать сообщение всем игрокам на твоей поверхности. (карты могут быть разделены на поверхности)
* /admins-send \<сообщение\> - Послать сообщение администраторам.
* /toggle-chat [\<all/faction/allied/local/surface/admins/drop-down\>] - Изменить части пользовательского интерфейса чата.

## <a name="Optional"></a> Зависимости

### <a name="required"></a> Необходимые

* [Event listener](https://mods.factorio.com/mod/event-listener)

### <a name="embedded"></a> Необязательные

* [Color picker](https://forums.factorio.com/viewtopic.php?f=97&t=30657)

## <a name="issue"></a> Нашли ошибку?

Пожалуйста, сообщайте о любых проблемах или ошибках в документации, вы можете помочь нам
[submitting an issue](https://gitlab.com/ZwerOxotnik/secondary-chat/issues) на нашем GitLab репозитории или сообщите на [mods.factorio.com](https://mods.factorio.com/mod/secondary-chat/discussion).

## <a name="feature"></a> Хотите новую функцию?

Вы можете *запросить* новую функцию [submitting an issue](https://gitlab.com/ZwerOxotnik/secondary-chat/issues) на нашем GitLab репозитории или сообщите на [mods.factorio.com](https://mods.factorio.com/mod/secondary-chat/discussion).

## <a name="installing"></a> Установка

Если вы скачали zip архив:

* просто поместите его в директорию модов.

Для большей информации, смотрите [вики Factorio "загрузка и установка модов"](https://wiki.factorio.com/Modding/ru#.D0.97.D0.B0.D0.B3.D1.80.D1.83.D0.B7.D0.BA.D0.B0_.D0.B8_.D1.83.D1.81.D1.82.D0.B0.D0.BD.D0.BE.D0.B2.D0.BA.D0.B0_.D0.BC.D0.BE.D0.B4.D0.BE.D0.B2).

Если вы скачали исходный архив (GitLab):

* скопируйте данный мод в директорию модов Factorio
* переименуйте данный мод в secondary-chat_*версия*, где *версия* это версия мода, которую вы скачали (например, 1.22.4)

## <a name="special-thanks"></a> Особая благодарность

* **MeteorSbor** - тестировщик
* **midaw** - тестировщик
* **HAKER PLAY** - переводчик
* **anonymous#1** - переводчик
* [XMKTP](https://mods.factorio.com/mod/XMKTP) - Xagros's Mods Korean Translation Project

## <a name="license"></a> Лицензия

Этот проект защищен авторским правом © 2017-2023 ZwerOxotnik \<zweroxotnik@gmail.com\>.

Использование исходного кода, включенного здесь, регламентируется European Union Public License v. 1.2 только. Смотрите [LICENCE](/LICENCE) файл для разбора.

[homepage]: http://mods.factorio.com/mod/secondary-chat
[Factorio]: https://factorio.com/

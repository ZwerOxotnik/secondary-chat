-- Copyright (C) 2017-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the EUPL, Version 1.2 only (the "LICENCE");

data:extend(
{ 
	{
		type = 'custom-input',
		name = 'message-send-to-chat',
		key_sequence = 'Y',
		consuming = 'game-only',
		enabled = true
	},
	{
		type = 'custom-input',
		name = 'locale-send-to-chat',
		key_sequence = 'SHIFT + Y',
		consuming = 'game-only',
		enabled = true
	},
	{
		type = 'custom-input',
		name = 'last-message-from-chat',
		key_sequence = 'CONTROL + Y',
		consuming = 'game-only',
		enabled = true
	},
	{
		type = 'custom-input',
		name = 'send-to-private',
		key_sequence = 'mouse-button-3',
		consuming = 'game-only',
		enabled = true
	},
	{
		type = 'custom-input',
		name = 'send-to-faction',
		key_sequence = 'SHIFT + mouse-button-3',
		consuming = 'game-only',
		enabled = true
	}
})

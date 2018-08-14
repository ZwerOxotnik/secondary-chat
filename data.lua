data:extend(
{ 
  {
    type = 'flying-text',
    name = 'flying-text-chat',
    flags = {'not-on-map'},
    time_to_live = 350,
    speed = 0.01
  },
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
    name = 'send_to_private',
    key_sequence = 'mouse-button-3',
    consuming = 'game-only',
    enabled = true
  },
  {
    type = 'custom-input',
    name = 'send_to_faction',
    key_sequence = 'SHIFT + mouse-button-3',
    consuming = 'game-only',
    enabled = true
  }
})

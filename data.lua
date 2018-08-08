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
    key_sequence = 'ENTER',
    consuming = 'game-only',
    enabled = true
  },
  {
    type = 'custom-input',
    name = 'locale-send-to-chat',
    key_sequence = 'SHIFT + ENTER',
    consuming = 'game-only',
    enabled = true
  },
  {
    type = 'custom-input',
    name = 'last-message-from-chat',
    key_sequence = 'CONTROL + ENTER',
    consuming = 'game-only',
    enabled = true
  }
})

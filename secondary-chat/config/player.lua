local config = {}

config.get_info = function()
  return {
    main = {
      
    }
  }
end

config.get_settings = function()
  return {
    main = {
      state_chat = {state = true, access = true, allow_save = true},
      with_tag = {state = true, access = true, allow_save = true},
      auto_focus = {state = false, access = true, allow_save = true},
      drop_down = {state = true, access = true, allow_save = true}
    },
    hidden = {
      allow_write = {state = true, allow_save = false}
    }
  }
end

return config

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
      state_chat = {state = true, access = true},
      with_tag = {state = true, access = true},
      auto_focus = {state = false, access = true},
      drop_down = {state = true, access = true}
    },
    hidden = {
      allow_write = {state = true}
    }
  }
end

return config

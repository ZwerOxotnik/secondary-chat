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
      state_chat = {state = true, access = true, allow_show_fast = false},
      with_tag = {state = true, access = true, allow_show_fast = true},
      auto_focus = {state = false, access = true, allow_show_fast = true},
      drop_down = {state = true, access = true, allow_show_fast = true}
    },
    hidden = {
      allow_write = {state = true, allow_show_fast = false}
    }
  }
end

return config

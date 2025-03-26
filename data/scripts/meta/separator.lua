-- Initialize sensor behavior specific to this quest.

require("scripts/multi_events")

local separator_meta = sol.main.get_metatable("separator")

separator_meta:register_event("on_created", function(separator)
  local game = separator:get_game()
  local hero = game:get_hero()

  -- Disable the separator if the savegame value passed in property is true
  if separator:get_property("disable_if_value") ~= nil then
    if game:get_value(separator:get_property("disable_if_value")) then
      separator:set_enabled(false)
    end
  end

  -- Enable the separator if the savegame value passed in property is true
  if separator:get_property("enable_if_value") ~= nil then
    if game:get_value(separator:get_property("enable_if_value")) then
      separator:set_enabled(true)
    end
  end

end)

separator_meta:register_event("on_activating", function(separator, direction4)

  local hero = separator:get_map():get_hero()
  local game = separator:get_game()
  local map = separator:get_map()
  local name = separator:get_name()

  if name == nil then
    return
  end

  -- Secret Rooms and secret sound
  if name:match("^secret_separator") then
    if direction4 == tonumber(separator:get_property("direction_trigger")) then sol.audio.play_sound("secret") end
  end

end)

return true
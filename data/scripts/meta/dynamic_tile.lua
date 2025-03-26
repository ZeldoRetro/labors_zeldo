-- Initialize dynamic tiles behavior specific to this quest.

require("scripts/multi_events")

local dynamic_tile_meta = sol.main.get_metatable("dynamic_tile")

dynamic_tile_meta:register_event("on_created",function(dynamic_tile)

  local game = dynamic_tile:get_game()
  local name = dynamic_tile:get_name()

  -- Disable the tile if the savegame value passed in property is true (an opened door for example)
  if dynamic_tile:get_property("disable_if_value") ~= nil then
    if game:get_value(dynamic_tile:get_property("disable_if_value")) then
      dynamic_tile:set_enabled(false)
    end
  end

  -- Enable the tile if the savegame value passed in property is true
  if dynamic_tile:get_property("enable_if_value") ~= nil then
    if game:get_value(dynamic_tile:get_property("enable_if_value")) then
      if dynamic_tile:get_property("value_number") ~= nil then
        if game:get_value(dynamic_tile:get_property("enable_if_value")) == tonumber(dynamic_tile:get_property("value_number")) then dynamic_tile:set_enabled(true) end
      else dynamic_tile:set_enabled(true) end
    end
  end

  if name == nil then
    return
  end

  if name:match("^invisible_tile") then
    dynamic_tile:set_visible(false)
  end
  if name:match("^invisible_path") then
    dynamic_tile:set_visible(false)
  end
  if name:match("^torch_path") then
    dynamic_tile:set_visible(false)
  end

  if name:match("^dev_entity") then
    dynamic_tile:set_visible(false)
  end
end)

return true
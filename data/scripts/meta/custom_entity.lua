-- Initialize custom entities behavior specific to this quest.

require("scripts/multi_events")

local custom_entity_meta = sol.main.get_metatable("custom_entity")

custom_entity_meta:register_event("on_created", function(custom_entity)

  local game = custom_entity:get_game()

  -- Disable the tile if the savegame value passed in property is true (an opened door for example)
  if custom_entity:get_property("disable_if_value") ~= nil then
    if game:get_value(custom_entity:get_property("disable_if_value")) then
      if custom_entity:get_property("value_number") ~= nil then
        if game:get_value(custom_entity:get_property("disable_if_value")) == tonumber(custom_entity:get_property("value_number")) then custom_entity:set_enabled(false) end
      elseif custom_entity:get_property("amount_number") ~= nil then
        if game:get_value(custom_entity:get_property("disable_if_value")) >= tonumber(custom_entity:get_property("amount_number")) then custom_entity:set_enabled(false) end
      else custom_entity:set_enabled(false) end
    end
  end

  -- Enable the tile if the savegame value passed in property is true
  if custom_entity:get_property("enable_if_value") ~= nil then
    if game:get_value(custom_entity:get_property("enable_if_value")) then
      if custom_entity:get_property("value_number") ~= nil then
        if game:get_value(custom_entity:get_property("enable_if_value")) == tonumber(custom_entity:get_property("value_number")) then custom_entity:set_enabled(true) end
      elseif custom_entity:get_property("amount_number") ~= nil then
        if game:get_value(custom_entity:get_property("enable_if_value")) >= tonumber(custom_entity:get_property("amount_number")) then custom_entity:set_enabled(true) end
      else custom_entity:set_enabled(true) end
    end
  end

  local name = custom_entity:get_name()
  if name == nil then
    return
  end

  if name:match("^invisible_tile") then
    custom_entity:set_visible(false)
  end
  if name:match("^invisible_path") then
    custom_entity:set_visible(false)
  end
end)

return true
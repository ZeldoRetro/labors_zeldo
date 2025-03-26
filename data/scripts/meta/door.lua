-- Initialize doors behavior specific to this quest.

require("scripts/multi_events")

local door_meta = sol.main.get_metatable("door")

door_meta:register_event("on_created", function(door)
  local game = door:get_game()
  local map = game:get_map()
  local hero = game:get_hero()

  -- Set an opened door with a property
  if door:get_property("set_door_open") ~= nil then
    if door:get_property("set_door_open") then
      map:set_doors_open(door:get_name())
    end
  end

  -- Disable the door if the savegame value passed in property is true
  if door:get_property("disable_if_value") ~= nil then
    if game:get_value(door:get_property("disable_if_value")) then
      door:set_enabled(false)
    end
  end

  -- Enable the door if the savegame value passed in property is true
  if door:get_property("enable_if_value") ~= nil then
    if game:get_value(door:get_property("enable_if_value")) then
      door:set_enabled(true)
    end
  end

end)

function door_meta:on_opened()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  --Murs fissurés: son de secret quand on les ouvre
  if name:match("^weak_door") then
    sol.audio.play_sound("secret")
  end
end

return true
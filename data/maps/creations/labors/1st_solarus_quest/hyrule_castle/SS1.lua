local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)

  -- Niveau de l'eau et escaliers
  if game:get_value("dungeon_10017_water_level") == 1 then 
    map:set_entities_enabled("water_low",false)
  end
end)
local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  if game:get_value("night") or game:get_value("dawn") then
    map:set_entities_enabled("night_entity",true)
  end
end)
local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  snores:set_enabled(false)
end)
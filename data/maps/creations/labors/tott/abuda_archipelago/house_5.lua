local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:set_speed(64)
  movement:start(npc)
end

--DEBUT DE LA MAP
function map:on_started(destination)
  npc_walk(boy_2)
end
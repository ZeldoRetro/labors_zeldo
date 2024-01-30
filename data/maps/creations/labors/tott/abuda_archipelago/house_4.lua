local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(npc)
end

--DEBUT DE LA MAP
function map:on_started(destination)
  npc_walk(npc)
  if game:get_value("night") or game:get_value("dawn") then
    npc:set_enabled(false)
  end
end
local map = ...
local game = map:get_game()

--BACKGROUND ARBRES
local trees = sol.surface.create("backgrounds/trees.png")

map:register_event("on_draw",function(map,dst_surface)
  trees:draw(dst_surface)
end)
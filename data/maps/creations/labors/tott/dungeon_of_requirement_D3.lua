local map = ...
local game = map:get_game()

function map:on_started()
  tp_switch_next:set_activated(true)
  tp_switch_previous:set_activated(true)
end

function map:on_opening_transition_finished()
  sol.timer.start(map,1000,function()
    tp_switch_next:set_activated(false)
    tp_switch_previous:set_activated(false)
  end)
end

function tp_switch_next:on_activated()
  hero:teleport("creations/labors/tott/dungeon_of_requirement_D4","previous","immediate")
end

function tp_switch_previous:on_activated()
  hero:teleport("creations/labors/tott/dungeon_of_requirement_D2","next","immediate")
end

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(80)
heat:fill_color({255,40,0})

map:register_event("on_draw",function(map,dst_surface)
  heat:draw(dst_surface)
end)
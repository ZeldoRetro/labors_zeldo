local map = ...
local game = map:get_game()

--EFFET DE CHALEUR
local heat = sol.surface.create(432,240)
heat:set_opacity(65)
heat:fill_color({255,40,0})

map:register_event("on_draw",function(map,dst_surface)
  heat:draw(dst_surface)
end)

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  for entity in map:get_entities("torch_path") do
  	entity:set_visible(false)
  end

  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

end)

--TORCHES QUI REVELENT CHEMIN INVISIBLE
local lit = 0
for torch in map:get_entities("torch_reveals_path") do
  torch:set_duration(7500)
  function torch:on_lit()
    lit = lit + 1
    for entity in map:get_entities("torch_path") do
    	entity:set_visible(true)
    end
  end
  function torch:on_unlit()
    lit = lit - 1
    if lit == 0 then
      for entity in map:get_entities("torch_path") do
      	entity:set_visible(false)
      end
    end
  end
end
local map = ...
local game = map:get_game()

--EFFET DE CHALEUR
local heat = sol.surface.create(432,240)
heat:set_opacity(50)
heat:fill_color({255,40,0})

map:register_event("on_draw",function(map,dst_surface)
  heat:draw(dst_surface)
end)

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)

  game:set_value("dark_room",true)
  sol.timer.start(map,10,function() game:set_value("dark_room",false) end)

  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

  for torch in map:get_entities("auto_timed_torch_auto_door_5") do
    torch:set_duration(26000)
  end

end)

--PORTES INVISIBLES
function secret_separator:on_activating(direction4)
  if direction4 == 3 then sol.audio.play_sound("secret") end
end
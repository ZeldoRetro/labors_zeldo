local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(80)
heat:fill_color({255,40,0})

map:register_event("on_draw",function(map,dst_surface)
  heat:draw(dst_surface)
end)



--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_6_back")
  map:set_doors_open("auto_door_7_back")

  --Miniboss vaincu
  map:set_entities_enabled("miniboss",false)
  if game:get_value("miniboss_10004") then
    agahnim_sprite:set_enabled(false)
    sensor_miniboss:set_enabled(false)
    map:set_doors_open("door_miniboss")
  else map:set_doors_open("door_miniboss_1") map:set_entities_enabled("telep_miniboss",false) end
  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_10004") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

end

--PORTES OUVERTES: COMBATS
if game:get_value("door_10004_6") then sensor_falling_auto_door_6_back:set_enabled(false) end
if game:get_value("door_10004_7") then sensor_falling_auto_door_7_back:set_enabled(false) end
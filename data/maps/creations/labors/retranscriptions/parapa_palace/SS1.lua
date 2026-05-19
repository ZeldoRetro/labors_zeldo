local map = ...
local game = map:get_game()
local music_map = map:get_music()


--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("wave",false)

  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)

  --Bataille 1 faite
  if game:get_value("battle_10022_1") then
    map:set_entities_enabled("sensor_battle_1",false)
    map:set_doors_open("door_battle")
  else map:set_doors_open("door_battle_1_1") end
end)

--BATAILLE 1
local wave = 1
function sensor_battle_1:on_activated()
  map:close_doors("door_battle_1_1")
  sol.audio.play_music("none")
  hero:freeze()
  sol.timer.start(1000,function()
    hero:unfreeze()
    sol.audio.play_music("battle")
    sensor_battle_1:set_enabled(false)
    map:set_entities_enabled("wave_1_enemy_",true)
  end)   
end
local function battle_clear()
  local door_x, door_y = map:get_entity("door_battle_1_2"):get_position()
  map:move_camera(door_x,door_y,256,function() 
    map:open_doors("door_battle")
    game:set_value("battle_10022_1",true)
    map:set_entities_enabled("telep_miniboss",true)
    sol.audio.play_music(music_map)
  end) 
end
function map:on_update()
  for enemy in map:get_entities("wave_"..wave.."_enemy") do
    enemy.on_dead = function()
      if not map:has_entities("wave_"..wave.."_enemy") then
        sol.audio.play_sound("correct")
        wave = wave + 1
  		  map:set_entities_enabled("wave_"..wave.."_enemy",true)
        --Au bout de 3 vagues, fin de la bataille
        if wave == 4 then
          battle_clear()      
        end
      end
    end
  end
end
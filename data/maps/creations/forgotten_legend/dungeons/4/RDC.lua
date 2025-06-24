local map = ...
local game = map:get_game()

local init_evil_tiles = sol.main.load_file("maps/lib/evil_tiles")
init_evil_tiles(map)


--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_1_back")

  -- Dalles piégées
  map:set_entities_enabled("evil_tile_", false)
  map:set_doors_open("evil_tiles_door", true)

  --Blocs raccourci 1 baissés
  if game:get_value("kokiri_shrine_shortcut_block_1_opened") then
    map:set_doors_open("kokiri_shrine_shortcut_block_1")
    kokiri_shrine_shortcut_block_1_wall:set_enabled(false)
    kokiri_shrine_shortcut_block_1_switch:set_activated(true)
  end
  --Blocs raccourci 2 baissés
  if game:get_value("kokiri_shrine_shortcut_block_2_opened") then
    map:set_doors_open("kokiri_shrine_shortcut_block_2")
    kokiri_shrine_shortcut_block_2_wall:set_enabled(false)
    kokiri_shrine_shortcut_block_2_switch:set_activated(true)
  end

  --Énigme ordre de switches résolue
  if game:get_value("door_4_2") then
    tiles_puzzle_switch_E:set_activated(true)
    tiles_puzzle_switch_W:set_activated(true)
    tiles_puzzle_switch_S:set_activated(true)
    tiles_puzzle_switch_N:set_activated(true)
    tiles_puzzle_switch_E:set_locked(true)
    tiles_puzzle_switch_W:set_locked(true)
    tiles_puzzle_switch_S:set_locked(true)
    tiles_puzzle_switch_N:set_locked(true)
    reset_evil_tiles:set_enabled(false)
    evil_tiles_sensor_1:set_enabled(false)
    map:set_entities_enabled("evil_tile_after_",true)
  end

  --Portes temporaires passées
  if game:get_value("kokiri_shrine_timed_door_2") then
    map:set_doors_open("timed_door_2")
    timed_door_2_switch:set_activated(true)
    sensor_pass_timed_door_2:set_enabled(false)
  end

  --Miniboss vaincu
  if not game:get_value("miniboss_4") == true then map:set_entities_enabled("telep_miniboss",false) end

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_4") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end
end)

--PORTES OUVERTES: COMBATS
if game:get_value("door_4_1") then sensor_falling_auto_door_1_back:set_enabled(false) end

--RACCOURCI DE BLOCS
function kokiri_shrine_shortcut_block_1_switch:on_activated()
  local volume = sol.audio.get_sound_volume()
  sol.audio.set_sound_volume(0)
  map:open_doors("kokiri_shrine_shortcut_block_1")
  kokiri_shrine_shortcut_block_1_wall:set_enabled(false)
  sol.audio.set_sound_volume(volume)
end
function kokiri_shrine_shortcut_block_2_switch:on_activated()
  local volume = sol.audio.get_sound_volume()
  sol.audio.set_sound_volume(0)
  map:open_doors("kokiri_shrine_shortcut_block_2")
  kokiri_shrine_shortcut_block_2_wall:set_enabled(false)
  sol.audio.set_sound_volume(volume)
end

--DALLES PIEGEES
for sensor in map:get_entities("evil_tiles_sensor") do
  function sensor:on_activated()
    map:set_entities_enabled("evil_tiles_sensor",false)
    map:close_doors("evil_tiles_door")
    sol.timer.start(6000, function()
      map:start_evil_tiles()
    end)
  end
end
function map:finish_evil_tiles()
  map:open_doors("evil_tiles_door")
end
function reset_evil_tiles:on_activated()
  map:set_entities_enabled("evil_tiles_sensor",true)
  map:create_enemy({
    x = 1496,
    y = 589,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_1",
  })
  map:create_enemy({
    x = 1384,
    y = 621,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_2",
  })
  map:create_enemy({
    x = 1464,
    y = 653,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_3",
  })
  map:create_enemy({
    x = 1416,
    y = 557,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_4",
  })
  map:set_entities_enabled("evil_tile_", false)
end

--ÉNIGME ORDRE DE SWITCHES (E W S N)
local switches_sequence = 0
function tiles_puzzle_switch_E:on_activated()
  if switches_sequence == 0 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_W:on_activated()
  if switches_sequence == 1 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_S:on_activated()
  if switches_sequence == 2 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_N:on_activated()
  if switches_sequence == 3 then
    tiles_puzzle_switch_E:set_activated(true)
    tiles_puzzle_switch_W:set_activated(true)
    tiles_puzzle_switch_S:set_activated(true)
    tiles_puzzle_switch_N:set_activated(true)
    tiles_puzzle_switch_E:set_locked(true)
    tiles_puzzle_switch_W:set_locked(true)
    tiles_puzzle_switch_S:set_locked(true)
    tiles_puzzle_switch_N:set_locked(true)
    reset_evil_tiles:set_enabled(false)
    auto_switch_auto_door_2:on_activated()
  else switches_sequence = 0 end
end

--SWITCHES ET PORTES TEMPORAIRES
local timer
function timed_door_2_switch:on_activated()
  local door_x,door_y = timed_door_2:get_position()
  sol.audio.play_sound("correct")
  map:move_camera(door_x,door_y,256,function() 
    map:open_doors("timed_door_2")
    timer = sol.timer.start(map, 10000, function()
      sol.audio.play_sound("wrong")
      map:close_doors("timed_door_2")
      timed_door_2_switch:set_activated(false)
    end)
    timer:set_with_sound(true)
  end)  
end
function sensor_pass_timed_door_2:on_activated()
  self:set_enabled(false)
  sol.audio.play_sound("secret")
  timer:stop()
  game:set_value("kokiri_shrine_timed_door_2",true)
end
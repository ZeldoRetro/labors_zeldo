local map = ...
local game = map:get_game()

local init_evil_tiles = sol.main.load_file("maps/lib/evil_tiles")
init_evil_tiles(map)


--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_5_back")
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

  -- Dalles piégées
  map:set_entities_enabled("evil_tile_", false)
  map:set_doors_open("evil_tiles_door", true)

  --Blocs "raccourci" baissés
  if game:get_value("kokiri_shrine_shortcut_block_3_opened") then
    map:set_doors_open("kokiri_shrine_shortcut_block_1")
    kokiri_shrine_shortcut_block_1_wall:set_enabled(false)
    kokiri_shrine_shortcut_block_1_switch:set_activated(true)
  end

  --Énigme ordre de switches résolue
  if game:get_value("door_4_6") then
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

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_4") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

  --Pas de musique dans la zone de pré-boss
  if destination == escalier_centre_2 then sol.audio.play_music("none") end
end)

--PORTES OUVERTES: COMBATS
if game:get_value("door_4_5") then sensor_falling_auto_door_5_back:set_enabled(false) end

--RACCOURCI DE BLOCS
function kokiri_shrine_shortcut_block_1_switch:on_activated()
  local volume = sol.audio.get_sound_volume()
  sol.audio.set_sound_volume(0)
  map:open_doors("kokiri_shrine_shortcut_block_1")
  kokiri_shrine_shortcut_block_1_wall:set_enabled(false)
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
    x = 536,
    y = 621,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_1",
  })
  map:create_enemy({
    x = 536,
    y = 589,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_7",
  })
  map:create_enemy({
    x = 504,
    y = 557,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_5",
  })
  map:create_enemy({
    x = 504,
    y = 653,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_4",
  })
  map:create_enemy({
    x = 456,
    y = 557,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_6",
  })
  map:create_enemy({
    x = 456,
    y = 653,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_8",
  })
  map:create_enemy({
    x = 424,
    y = 589,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_3",
  })
  map:create_enemy({
    x = 424,
    y = 621,
    layer = 2,
    breed = "evil_tile",
    direction = 1,
    name = "evil_tile_enemy_2",
  })
  map:set_entities_enabled("evil_tile_", false)
end

--ÉNIGME ORDRE DE SWITCHES (N W S W)
local switches_sequence = 0
function tiles_puzzle_switch_E:on_activated()
  switches_sequence = 0
  print(switches_sequence)
end
function tiles_puzzle_switch_W:on_activated()
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
    auto_switch_auto_door_6:on_activated()
  elseif switches_sequence == 1 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
end
function tiles_puzzle_switch_S:on_activated()
  if switches_sequence == 2 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
end
function tiles_puzzle_switch_N:on_activated()
  if switches_sequence == 0 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
end

--PORTES INVISIBLES: SONS SECRETS
function secret_separator_2:on_activating(direction4)
  if direction4 == 1 then sol.audio.play_sound("secret") end
end
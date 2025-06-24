local map = ...
local game = map:get_game()

--CRISTAUX ET EFFETS DE LUMIÈRE
 
local can_touch = true
local function activating_crystal()
  can_touch = false
  if map:get_crystal_state() == true then
    map:set_entities_enabled("crystal_blue_light_",true)
    map:set_entities_enabled("crystal_red_light_",false)
  else
    map:set_entities_enabled("crystal_blue_light_",false)
    map:set_entities_enabled("crystal_red_light_",true)
  end
  sol.timer.start(map,200,function() can_touch = true end)
end

function map:on_opening_transition_finished()
  if map:get_crystal_state() == true then
    map:set_entities_enabled("crystal_blue_light_",true)
    map:set_entities_enabled("crystal_red_light_",false)
  else
    map:set_entities_enabled("crystal_blue_light_",false)
    map:set_entities_enabled("crystal_red_light_",true)
  end

  crystal_sensor_1:add_collision_test("touching", activating_crystal)
  crystal_sensor_2:add_collision_test("touching", activating_crystal)
  crystal_sensor_3:add_collision_test("touching", activating_crystal)
end


--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)

  --map:set_darkness_level({112,112,112})

  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_entities_enabled("miniboss",false)
  map:set_doors_open("auto_door_4_back_2")

  --Portes temporaires passées
  if game:get_value("kokiri_shrine_timed_door_1") then
    map:set_doors_open("timed_door_1")
    timed_door_1_switch:set_activated(true)
    torch_1_6:set_lit(true)
    sensor_pass_timed_door_1:set_enabled(false)
  end

  --Clé 5 obtenue
  if game:get_value("key_4_5") then auto_chest_key_5:set_enabled(true) end

  --Énigme ordre de switches résolue
  if game:get_value("key_4_3") then
    tiles_puzzle_switch_1:set_activated(true)
    tiles_puzzle_switch_2:set_activated(true)
    tiles_puzzle_switch_3:set_activated(true)
    tiles_puzzle_switch_4:set_activated(true)
    torch_1_1:set_lit(true)
    torch_1_2:set_lit(true)
    torch_1_3:set_lit(true)
    torch_1_4:set_lit(true)
    auto_chest_key_3:set_enabled(true)
  end

  --Miniboss vaincu
  if game:get_value("miniboss_4") then
    sensor_miniboss:set_enabled(false)
    map:set_doors_open("door_miniboss")
  else map:set_doors_open("door_miniboss_1") map:set_entities_enabled("telep_miniboss",false) end
end)

--PORTES OUVERTES: COMBATS
if game:get_value("door_4_4") then   map:set_doors_open("auto_door_4_back") sensor_falling_auto_door_4_back_2:set_enabled(false) end

--ÉNIGME ORDRE DE SWITCHES (1 2 3 4)
local switches_sequence = 0
function tiles_puzzle_switch_1:on_activated()
  if switches_sequence == 0 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
  torch_1_1:set_lit(true)
  torch_1_1:on_lit()
  sol.timer.start(map, 500, function()
    tiles_puzzle_switch_1:set_activated(false)
    torch_1_1:set_lit(false)
    torch_1_1:on_unlit()
  end)
end
function tiles_puzzle_switch_2:on_activated()
  if switches_sequence == 1 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
  torch_1_2:set_lit(true)
  torch_1_2:on_lit()
  sol.timer.start(map, 500, function()
    tiles_puzzle_switch_2:set_activated(false)
    torch_1_2:set_lit(false)
    torch_1_2:on_unlit()
  end)
end
function tiles_puzzle_switch_3:on_activated()
  if switches_sequence == 2 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
  print(switches_sequence)
  torch_1_3:set_lit(true)
  torch_1_3:on_lit()
  sol.timer.start(map, 500, function()
    tiles_puzzle_switch_3:set_activated(false)
    torch_1_3:set_lit(false)
    torch_1_3:on_unlit()
  end)
end
function tiles_puzzle_switch_4:on_activated()
  if switches_sequence == 3 then
    tiles_puzzle_switch_1:set_activated(true)
    tiles_puzzle_switch_2:set_activated(true)
    tiles_puzzle_switch_3:set_activated(true)
    tiles_puzzle_switch_4:set_activated(true)
    torch_1_1:set_lit(true)
    torch_1_1:on_lit()
    torch_1_2:set_lit(true)
    torch_1_2:on_lit()
    torch_1_3:set_lit(true)
    torch_1_3:on_lit()
    torch_1_4:set_lit(true)
    torch_1_4:on_lit()
    auto_switch_auto_chest_key_3:on_activated()
  else
    switches_sequence = 0
    torch_1_4:set_lit(true)
    torch_1_4:on_lit()
    sol.timer.start(map, 500, function()
      tiles_puzzle_switch_4:set_activated(false)
      torch_1_4:set_lit(false)
      torch_1_4:on_unlit()
    end)
  end
  print(switches_sequence)
end

--SWITCHES ET PORTES TEMPORAIRES
local timer
function timed_door_1_switch:on_activated()
  local door_x,door_y = timed_door_1:get_position()
  sol.audio.play_sound("correct")
  torch_1_6:set_lit(true)
  torch_1_6:on_lit()
  map:move_camera(door_x,door_y,256,function() 
    map:open_doors("timed_door_1")
    timer = sol.timer.start(map, 4000, function()
      sol.audio.play_sound("wrong")
      torch_1_6:set_lit(false)
      torch_1_6:on_unlit()
      map:close_doors("timed_door_1")
      timed_door_1_switch:set_activated(false)
    end)
    timer:set_with_sound(true)
  end)  
end
function sensor_pass_timed_door_1:on_activated()
  self:set_enabled(false)
  sol.audio.play_sound("secret")
  timer:stop()
  game:set_value("kokiri_shrine_timed_door_1",true)
end

--TROUS CACHÉS ET BUISSONS
for destructible in map:get_entities("bush_hole_") do
  function destructible:on_lifting()
    map:set_entities_enabled(destructible:get_name().."_ground",false)
  end
  function destructible:on_cut()
    map:set_entities_enabled(destructible:get_name().."_ground",false)
  end
end
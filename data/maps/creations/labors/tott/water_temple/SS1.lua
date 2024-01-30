local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

for block in map:get_entities("block_puzzle_1_") do
  function block:on_moved()
    block:set_max_moves(block:get_max_moves() - 1)
    block:get_sprite():set_direction(block:get_max_moves())
  end
end


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_3_back")

  --Etat des interrupteurs d'eau suivant le niveau de l'eau
  map:set_entities_enabled("water_middle",false)
  map:set_entities_enabled("water_flux",false)
  if game:get_value("water_temple_water_level") >= 3 then 
    switch_water_add_1:set_activated(true)
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
  else 
    switch_water_remove_1:set_activated(true) 
    map:set_entities_enabled("water_high",false)
  end

  --Clé 1 obtenue
  if game:get_value("key_10001_1") then 
    auto_chest_key_1:set_enabled(true) 
    auto_switch_auto_chest_key_1:set_enabled(true)
    block_puzzle_1_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_1_switch_1:get_position()
    local x2, y2 = block_puzzle_1_switch_2:get_position()
    block_puzzle_1_block_1:set_position(x1 + 8, y1 + 13)
    block_puzzle_1_block_1:set_pushable(false)
    block_puzzle_1_block_1:set_pullable(false)
    block_puzzle_1_block_2:set_position(x2 + 8, y2 + 13)
    block_puzzle_1_block_2:set_pushable(false)
    block_puzzle_1_block_2:set_pullable(false)
  else
    block_puzzle_1_block_1:get_sprite():set_direction(block_puzzle_1_block_1:get_max_moves())
    block_puzzle_1_block_2:get_sprite():set_direction(block_puzzle_1_block_2:get_max_moves())
    auto_switch_auto_chest_key_1:set_enabled(false) 
  end

  --Porte 2 ouverte
  if game:get_value("door_10001_2") then 
    auto_switch_auto_door_2:set_enabled(true)
    block_puzzle_2_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_2_switch_1:get_position()
    local x2, y2 = block_puzzle_2_switch_2:get_position()
    local x3, y3 = block_puzzle_2_switch_3:get_position()
    local x4, y4 = block_puzzle_2_switch_4:get_position()
    block_puzzle_2_block_1:set_position(x1 + 8, y1 + 13)
    block_puzzle_2_block_1:set_pushable(false)
    block_puzzle_2_block_1:set_pullable(false)
    block_puzzle_2_block_2:set_position(x2 + 8, y2 + 13)
    block_puzzle_2_block_2:set_pushable(false)
    block_puzzle_2_block_2:set_pullable(false)
    block_puzzle_2_block_3:set_position(x3 + 8, y3 + 13)
    block_puzzle_2_block_3:set_pushable(false)
    block_puzzle_2_block_3:set_pullable(false)
    block_puzzle_2_block_4:set_position(x4 + 8, y4 + 13)
    block_puzzle_2_block_4:set_pushable(false)
    block_puzzle_2_block_4:set_pullable(false)
  else
    auto_switch_auto_door_2:set_enabled(false) 
  end

  --Escalier raccourci switch eau
  if game:get_value("dungeon_10001_stair_1") then
    map:set_entities_enabled("stair_sw_room",true)
    wall_stair_sw_room:set_enabled(false)
    wall_stair_sw_room_2:set_enabled(false)
    jumper_stair_sw_room:set_enabled(false)
    switch_stair_sw_room:set_activated(true)
  else map:set_entities_enabled("stair_sw_room",false) end

  --Miniboss vaincu
  if game:get_value("miniboss_10001") then map:set_entities_enabled("telep_miniboss",true) end
end

--ENIGME DE BLOCS POUR CLE 1
function block_puzzle_1_fake_switch:on_activated()
    sol.timer.start(500,function()
      block_puzzle_1_block_1:reset()
      block_puzzle_1_block_2:reset()
      block_puzzle_1_block_1:set_max_moves(3)
      block_puzzle_1_block_2:set_max_moves(1)
      block_puzzle_1_block_1:get_sprite():set_direction(block_puzzle_1_block_1:get_max_moves())
      block_puzzle_1_block_2:get_sprite():set_direction(block_puzzle_1_block_2:get_max_moves())
      sol.audio.play_sound("wrong") 
      block_puzzle_1_fake_switch:set_activated(false) 
    end)
end

local block_puzzle_1_switches = 0
local goal_block_puzzle_1 = 2
for switch in map:get_entities("block_puzzle_1_switch") do
  function switch:on_activated()
    block_puzzle_1_switches = block_puzzle_1_switches + 1
    if block_puzzle_1_switches == goal_block_puzzle_1 then
      auto_switch_auto_chest_key_1:set_enabled(true)
      block_puzzle_1_fake_switch:set_enabled(false)
    end
  end
  function switch:on_inactivated()
    block_puzzle_1_switches = block_puzzle_1_switches - 1
    auto_switch_auto_chest_key_1:set_enabled(false)
    block_puzzle_1_fake_switch:set_enabled(true)
  end
end

--ENIGME DE BLOCS POUR PORTE 2 (CODE)
function block_puzzle_2_fake_switch:on_activated()
    sol.timer.start(500,function()
      block_puzzle_2_block_1:reset()
      block_puzzle_2_block_2:reset()
      block_puzzle_2_block_3:reset()
      block_puzzle_2_block_4:reset()
      sol.audio.play_sound("wrong") 
      block_puzzle_2_fake_switch:set_activated(false) 
    end)
end

local block_puzzle_2_switches = 0
local goal_block_puzzle_2 = 4
for switch in map:get_entities("block_puzzle_2_switch") do
  function switch:on_activated()
    block_puzzle_2_switches = block_puzzle_2_switches + 1
    if block_puzzle_2_switches == goal_block_puzzle_2 then
      auto_switch_auto_door_2:set_enabled(true)
      block_puzzle_2_fake_switch:set_enabled(false)
    end
  end
  function switch:on_inactivated()
    block_puzzle_2_switches = block_puzzle_2_switches - 1
    auto_switch_auto_door_2:set_enabled(false)
    block_puzzle_2_fake_switch:set_enabled(true)
  end
end

--SWITCH POUR ESCALIER RACCOURCI SWITCH EAU
function switch_stair_sw_room:on_activated()
  sol.audio.play_sound("correct")
  map:move_camera(896,1288,256,function() 
    wall_stair_sw_room:set_enabled(false)
    wall_stair_sw_room_2:set_enabled(false)
    jumper_stair_sw_room:set_enabled(false)
    map:set_entities_enabled("stair_sw_room",true)
    sol.audio.play_sound("explosion")
    game:set_value("dungeon_10001_stair_1",true)
    sol.timer.start(1000,function() sol.audio.play_sound("secret") end)
  end)
end

--PORTES OUVERTES: COMBATS
if game:get_value("door_10001_4") then sensor_falling_auto_door_3_back:set_enabled(false) end

--PORTES INVISIBLES: SONS SECRETS
function secret_separator:on_activating(direction4)
  if direction4 == 3 then sol.audio.play_sound("secret") end
end

--SAUVEGARDE DE L'ETAT DE MORT DES ZOURAS SUIVANT LE NIVEAU D'EAU
function water_high_zoura_1:on_dead()
  if water_low_zoura_1 ~= nil then water_low_zoura_1:remove() end
end
function water_low_zoura_1:on_dead()
  if water_high_zoura_1 ~= nil then water_high_zoura_1:remove() end
end
function water_high_zoura_2:on_dead()
  if water_low_zoura_2 ~= nil then water_low_zoura_2:remove() end
end
function water_low_zoura_2:on_dead()
  if water_high_zoura_2 ~= nil then water_high_zoura_2:remove() end
end
function water_high_zoura_3:on_dead()
  if water_low_zoura_3 ~= nil then water_low_zoura_3:remove() end
end
function water_low_zoura_3:on_dead()
  if water_high_zoura_3 ~= nil then water_high_zoura_3:remove() end
end
function water_high_zoura_4:on_dead()
  if water_low_zoura_4 ~= nil then water_low_zoura_4:remove() end
end
function water_low_zoura_4:on_dead()
  if water_high_zoura_4 ~= nil then water_high_zoura_4:remove() end
end

--ACTIVATION DES INTERRUPTEURS ET GESTION DU NIVEAU DE L'EAU
function switch_water_remove_1:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.audio.play_sound("water_drain")
  sol.timer.start(1000,function()
    map:set_entities_enabled("water_high",false)
    map:set_entities_enabled("water_flux",false)
    map:set_entities_enabled("water_middle_1",true)
    sol.timer.start(1000,function()
      map:set_entities_enabled("water_middle_1",false)
      map:set_entities_enabled("water_middle_2",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("water_middle_2",false)
        map:set_entities_enabled("water_low",true)
        sol.audio.play_sound("secret")
        switch_water_add_1:set_activated(false)
        game:set_value("water_temple_water_level",2)
        hero:unfreeze()
      end)
    end)
  end)
end
function switch_water_add_1:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.audio.play_sound("water_fill")
  sol.timer.start(1000,function()
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
      map:set_entities_enabled("water_middle_2",true)
      map:set_entities_enabled("water_flux_1",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("water_middle_2",false)
        map:set_entities_enabled("water_middle_1",true)
        map:set_entities_enabled("water_flux_1",false)
        map:set_entities_enabled("water_flux_2",true)
        sol.timer.start(1000,function()
          map:set_entities_enabled("water_middle_1",false)
          map:set_entities_enabled("water_flux_2",false)
          map:set_entities_enabled("water_high",true)
          map:set_entities_enabled("water_miniboss",true)
          map:set_entities_enabled("water_boss",true)
          sol.audio.play_sound("secret")
          switch_water_remove_1:set_activated(false)
          game:set_value("water_temple_water_level",3)
          hero:unfreeze()
        end)
      end)
  end)
end
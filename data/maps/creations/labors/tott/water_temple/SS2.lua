local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_entities_enabled("miniboss",false)
  map:set_doors_open("auto_door_2_back")

  --Etat des interrupteurs d'eau suivant le niveau de l'eau
  map:set_entities_enabled("water_middle",false)
  map:set_entities_enabled("water_flux",false)
  if game:get_value("water_temple_water_level") >= 2 then 
    switch_water_add_1:set_activated(true)
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
  else 
    switch_water_remove_1:set_activated(true) 
    map:set_entities_enabled("water_high",false)
  end

  --Escalier raccourci pièce centrale 1
  if game:get_value("dungeon_10001_stair_2") then
    map:set_entities_enabled("stair_central_room_1",true)
    wall_stair_central_room_1_1:set_enabled(false)
    wall_stair_central_room_1_2:set_enabled(false)
    jumper_stair_central_room_1:set_enabled(false)
    switch_stair_central_room_1:set_activated(true)
  else map:set_entities_enabled("stair_central_room_1",false) end

  --Escalier raccourci pièce centrale 2
  if game:get_value("dungeon_10001_stair_3") then
    map:set_entities_enabled("stair_central_room_2",true)
    wall_stair_central_room_2_1:set_enabled(false)
    wall_stair_central_room_2_2:set_enabled(false)
    jumper_stair_central_room_2:set_enabled(false)
    switch_stair_central_room_2:set_activated(true)
  else map:set_entities_enabled("stair_central_room_2",false) end

  --Clé 4 obtenue
  if game:get_value("key_10001_4") then 
    auto_chest_key_1:set_enabled(true)
    block_puzzle_1_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_1_switch_1:get_position()
    local x2, y2 = block_puzzle_1_switch_2:get_position()
    local x3, y3 = block_puzzle_1_switch_3:get_position()
    local x4, y4 = block_puzzle_1_switch_4:get_position()
    block_puzzle_1_block_1:set_position(x1 + 8, y1 + 13)
    block_puzzle_1_block_1:set_pushable(false)
    block_puzzle_1_block_1:set_pullable(false)
    block_puzzle_1_block_2:set_position(x2 + 8, y2 + 13)
    block_puzzle_1_block_2:set_pushable(false)
    block_puzzle_1_block_2:set_pullable(false)
    block_puzzle_1_block_3:set_position(x3 + 8, y3 + 13)
    block_puzzle_1_block_3:set_pushable(false)
    block_puzzle_1_block_3:set_pullable(false)
    block_puzzle_1_block_4:set_position(x4 + 8, y4 + 13)
    block_puzzle_1_block_4:set_pushable(false)
    block_puzzle_1_block_4:set_pullable(false)
  else
    auto_switch_auto_chest_key_1:set_enabled(false) 
  end

  --Miniboss vaincu
  if game:get_value("miniboss_10001") then
    sensor_miniboss:set_enabled(false)
    map:set_doors_open("door_miniboss")
  else map:set_doors_open("door_miniboss_1") map:set_entities_enabled("telep_miniboss",false) end
  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_10001") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

end

--SWITCH POUR ESCALIER RACCOURCI PIECE CENTRALE 1
function switch_stair_central_room_1:on_activated()
  sol.audio.play_sound("correct")
  map:move_camera(1128,832,256,function() 
    wall_stair_central_room_1_1:set_enabled(false)
    wall_stair_central_room_1_2:set_enabled(false)
    jumper_stair_central_room_1:set_enabled(false)
    map:set_entities_enabled("stair_central_room_1",true)
    sol.audio.play_sound("explosion")
    game:set_value("dungeon_10001_stair_2",true)
    sol.timer.start(1000,function() sol.audio.play_sound("secret") end)
  end)
end

--SWITCH POUR ESCALIER RACCOURCI PIECE CENTRALE 2
function switch_stair_central_room_2:on_activated()
  sol.audio.play_sound("correct")
  map:move_camera(1736,832,256,function() 
    wall_stair_central_room_2_1:set_enabled(false)
    wall_stair_central_room_2_2:set_enabled(false)
    jumper_stair_central_room_2:set_enabled(false)
    map:set_entities_enabled("stair_central_room_2",true)
    sol.audio.play_sound("explosion")
    game:set_value("dungeon_10001_stair_3",true)
    sol.timer.start(1000,function() sol.audio.play_sound("secret") end)
  end)
end

--PORTES OUVERTES: COMBATS
if game:get_value("door_10001_9") then sensor_falling_auto_door_2_back:set_enabled(false) end

--PORTES INVISIBLES: SONS SECRETS
function secret_separator:on_activating(direction4)
  if direction4 == 2 then sol.audio.play_sound("secret") end
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
function water_high_zoura_5:on_dead()
  if water_low_zoura_5 ~= nil then water_low_zoura_5:remove() end
end
function water_low_zoura_5:on_dead()
  if water_high_zoura_5 ~= nil then water_high_zoura_5:remove() end
end
function water_high_zoura_6:on_dead()
  if water_low_zoura_6 ~= nil then water_low_zoura_6:remove() end
end
function water_low_zoura_6:on_dead()
  if water_high_zoura_6 ~= nil then water_high_zoura_6:remove() end
end
function water_high_zoura_7:on_dead()
  if water_low_zoura_7 ~= nil then water_low_zoura_7:remove() end
end
function water_low_zoura_7:on_dead()
  if water_high_zoura_7 ~= nil then water_high_zoura_7:remove() end
end
function water_high_zoura_8:on_dead()
  if water_low_zoura_8 ~= nil then water_low_zoura_8:remove() end
end
function water_low_zoura_8:on_dead()
  if water_high_zoura_8 ~= nil then water_high_zoura_8:remove() end
end
function water_high_zoura_9:on_dead()
  if water_low_zoura_9 ~= nil then water_low_zoura_9:remove() end
end
function water_low_zoura_9:on_dead()
  if water_high_zoura_9 ~= nil then water_high_zoura_9:remove() end
end
function water_high_zoura_10:on_dead()
  if water_low_zoura_10 ~= nil then water_low_zoura_10:remove() end
end
function water_low_zoura_10:on_dead()
  if water_high_zoura_10 ~= nil then water_high_zoura_10:remove() end
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
        game:set_value("water_temple_water_level",1)
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
          game:set_value("water_temple_water_level",2)
          hero:unfreeze()
        end)
      end)
  end)
end

--ENIGME DE BLOCS POUR CLE 4 (CODE)
function block_puzzle_1_fake_switch:on_activated()
    sol.timer.start(500,function()
      block_puzzle_1_block_1:reset()
      block_puzzle_1_block_2:reset()
      block_puzzle_1_block_3:reset()
      block_puzzle_1_block_4:reset()
      sol.audio.play_sound("wrong") 
      block_puzzle_1_fake_switch:set_activated(false) 
    end)
end

local block_puzzle_1_switches = 0
local goal_block_puzzle_1 = 4
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
    block_puzzle_1_fake_switch:set_enabled(true)
    auto_switch_auto_chest_key_1:set_enabled(false)
  end
end
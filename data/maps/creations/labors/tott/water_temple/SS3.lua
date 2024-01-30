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

for block in map:get_entities("block_puzzle_2_") do
  function block:on_moved()
    block:set_max_moves(block:get_max_moves() - 1)
    block:get_sprite():set_direction(block:get_max_moves())
  end
end


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  block_code_1:get_sprite():set_direction(block_code_1:get_max_moves())
  block_code_2:get_sprite():set_direction(block_code_2:get_max_moves())
  block_code_3:get_sprite():set_direction(block_code_3:get_max_moves())
  block_puzzle_3_switch_1:set_visible(false)
  block_puzzle_3_switch_2:set_visible(false)
  block_puzzle_3_reset_1:set_visible(false)
  block_puzzle_3_reset_2:set_visible(false)
  block_puzzle_3_reset_3:set_visible(false)
  block_puzzle_3_reset_4:set_visible(false)

  --Etat des interrupteurs d'eau suivant le niveau de l'eau
  map:set_entities_enabled("water_middle",false)
  map:set_entities_enabled("water_flux",false)
  if game:get_value("water_temple_water_level") >= 1 then 
    switch_water_add_1:set_activated(true)
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
  else 
    switch_water_remove_1:set_activated(true) 
    map:set_entities_enabled("water_high",false)
  end

  --Clé 8 obtenue
  if game:get_value("key_10001_8") then 
    auto_chest_key_2:set_enabled(true)
    auto_switch_auto_chest_key_2:set_enabled(true)
    block_puzzle_3_fake_switch:set_enabled(false)
    block_puzzle_3_switch_1:set_activated(true)
    block_puzzle_3_switch_2:set_activated(true)
    block_puzzle_3_reset_1:set_activated(true)
    block_puzzle_3_reset_2:set_activated(true)
    block_puzzle_3_reset_3:set_activated(true)
    block_puzzle_3_reset_4:set_activated(true)
  else
    auto_switch_auto_chest_key_2:set_enabled(false) 
  end

  --Clé 9 obtenue
  if game:get_value("key_10001_9") then 
    auto_chest_key_1:set_enabled(true)
    auto_switch_auto_chest_key_1:set_enabled(true)
    block_puzzle_1_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_1_switch_1:get_position()
    local x2, y2 = block_puzzle_1_switch_2:get_position()
    local x3, y3 = block_puzzle_1_switch_3:get_position()
    local x4, y4 = block_puzzle_1_switch_4:get_position()
    local x5, y5 = block_puzzle_1_switch_5:get_position()
    local x6, y6 = block_puzzle_1_switch_6:get_position()
    local x7, y7 = block_puzzle_1_switch_7:get_position()
    local x8, y8 = block_puzzle_1_switch_8:get_position()
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
    block_puzzle_1_block_5:set_position(x5 + 8, y5 + 13)
    block_puzzle_1_block_5:set_pushable(false)
    block_puzzle_1_block_5:set_pullable(false)
    block_puzzle_1_block_6:set_position(x6 + 8, y6 + 13)
    block_puzzle_1_block_6:set_pushable(false)
    block_puzzle_1_block_6:set_pullable(false)
    block_puzzle_1_block_7:set_position(x7 + 8, y7 + 13)
    block_puzzle_1_block_7:set_pushable(false)
    block_puzzle_1_block_7:set_pullable(false)
    block_puzzle_1_block_8:set_position(x8 + 8, y8 + 13)
    block_puzzle_1_block_8:set_pushable(false)
    block_puzzle_1_block_8:set_pullable(false)
  else
    block_puzzle_1_block_1:get_sprite():set_direction(block_puzzle_1_block_1:get_max_moves())
    block_puzzle_1_block_2:get_sprite():set_direction(block_puzzle_1_block_2:get_max_moves())
    block_puzzle_1_block_3:get_sprite():set_direction(block_puzzle_1_block_3:get_max_moves())
    block_puzzle_1_block_4:get_sprite():set_direction(block_puzzle_1_block_4:get_max_moves())
    block_puzzle_1_block_5:get_sprite():set_direction(block_puzzle_1_block_5:get_max_moves())
    block_puzzle_1_block_6:get_sprite():set_direction(block_puzzle_1_block_6:get_max_moves())
    block_puzzle_1_block_7:get_sprite():set_direction(block_puzzle_1_block_7:get_max_moves())
    block_puzzle_1_block_8:get_sprite():set_direction(block_puzzle_1_block_8:get_max_moves())
    auto_switch_auto_chest_key_1:set_enabled(false) 
  end

  --Porte 8 ouverte
  if game:get_value("door_10001_8") then 
    auto_switch_auto_door_3:set_enabled(true)
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
    block_puzzle_2_block_1:set_max_moves(2)
    block_puzzle_2_block_2:set_max_moves(3)
    block_puzzle_2_block_3:set_max_moves(1)
    block_puzzle_2_block_4:set_max_moves(0)
    block_puzzle_2_block_1:get_sprite():set_direction(block_puzzle_2_block_1:get_max_moves())
    block_puzzle_2_block_2:get_sprite():set_direction(block_puzzle_2_block_2:get_max_moves())
    block_puzzle_2_block_3:get_sprite():set_direction(block_puzzle_2_block_3:get_max_moves())
    block_puzzle_2_block_4:get_sprite():set_direction(block_puzzle_2_block_4:get_max_moves())
  else
    block_puzzle_2_block_1:get_sprite():set_direction(block_puzzle_2_block_1:get_max_moves())
    block_puzzle_2_block_2:get_sprite():set_direction(block_puzzle_2_block_2:get_max_moves())
    block_puzzle_2_block_3:get_sprite():set_direction(block_puzzle_2_block_3:get_max_moves())
    block_puzzle_2_block_4:get_sprite():set_direction(block_puzzle_2_block_4:get_max_moves())
    auto_switch_auto_door_3:set_enabled(false) 
  end

  --Trésor 8 obtenu
  if game:get_value("rupees_10001_8") then
    auto_chest_rupee_1:set_enabled(true)
    local x1, y1 = auto_switch_auto_chest_rupee_1:get_position()
    block_puzzle_4_block:set_position(x1 + 8, y1 + 13)
    block_puzzle_4_block:set_pushable(false)
    block_puzzle_4_block:set_pullable(false)
  end

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_10001") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

  --Boss
  if game:get_value("boss_10001") then 
    sensor_boss:set_enabled(false) 
    map:set_doors_open("door_boss")
    local x, y = heart_container_spot:get_position()
    map:create_pickable{
      treasure_name = "quest_items/remembrance_shard",
      treasure_variant = 3,
      treasure_savegame_variable = "heart_container_10001",
      x = x,
      y = y,
      layer = 1
    }
  else map:set_doors_open("door_boss_1") boss:set_enabled(false) end

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
        game:set_value("water_temple_water_level",0)
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
          game:set_value("water_temple_water_level",1)
          hero:unfreeze()
        end)
      end)
  end)
end

--PORTES INVISIBLES: SONS SECRETS
function secret_separator:on_activating(direction4)
  if direction4 == 1 then sol.audio.play_sound("secret") end
end

--ENIGME POUR CLE 8: FRAPPER GRENOUILLES QUI NE CRACHENT PAS
local block_puzzle_3_switches = 0
function block_puzzle_3_fake_switch:on_activated()
    block_puzzle_3_switches = 0
    sol.timer.start(500,function()
      block_puzzle_3_switch_1:set_activated(false)
      block_puzzle_3_switch_2:set_activated(false)
      block_puzzle_3_reset_1:set_activated(false)
      block_puzzle_3_reset_2:set_activated(false)
      block_puzzle_3_reset_3:set_activated(false)
      block_puzzle_3_reset_4:set_activated(false)
      sol.audio.play_sound("wrong") 
      block_puzzle_3_fake_switch:set_activated(false) 
    end)
end

local goal_block_puzzle_3 = 2
for switch in map:get_entities("block_puzzle_3_switch") do
  function switch:on_activated()
    block_puzzle_3_switches = block_puzzle_3_switches + 1
    if block_puzzle_3_switches == goal_block_puzzle_3 then
      auto_switch_auto_chest_key_2:set_enabled(true)
      block_puzzle_3_fake_switch:set_enabled(false)
    end
  end
end
for switch in map:get_entities("block_puzzle_3_reset") do
  function switch:on_activated()
    block_puzzle_3_switches = 0
  end
end

--ENIGME DE BLOCS POUR CLE 9
function block_puzzle_1_fake_switch:on_activated()
    sol.timer.start(500,function()
      block_puzzle_1_block_1:reset()
      block_puzzle_1_block_2:reset()
      block_puzzle_1_block_3:reset()
      block_puzzle_1_block_4:reset()
      block_puzzle_1_block_5:reset()
      block_puzzle_1_block_6:reset()
      block_puzzle_1_block_7:reset()
      block_puzzle_1_block_8:reset()
      block_puzzle_1_block_1:set_max_moves(4)
      block_puzzle_1_block_2:set_max_moves(3)
      block_puzzle_1_block_3:set_max_moves(3)
      block_puzzle_1_block_4:set_max_moves(2)
      block_puzzle_1_block_5:set_max_moves(1)
      block_puzzle_1_block_6:set_max_moves(1)
      block_puzzle_1_block_7:set_max_moves(1)
      block_puzzle_1_block_8:set_max_moves(1)
      block_puzzle_1_block_1:get_sprite():set_direction(block_puzzle_1_block_1:get_max_moves())
      block_puzzle_1_block_2:get_sprite():set_direction(block_puzzle_1_block_2:get_max_moves())
      block_puzzle_1_block_3:get_sprite():set_direction(block_puzzle_1_block_3:get_max_moves())
      block_puzzle_1_block_4:get_sprite():set_direction(block_puzzle_1_block_4:get_max_moves())
      block_puzzle_1_block_5:get_sprite():set_direction(block_puzzle_1_block_5:get_max_moves())
      block_puzzle_1_block_6:get_sprite():set_direction(block_puzzle_1_block_6:get_max_moves())
      block_puzzle_1_block_7:get_sprite():set_direction(block_puzzle_1_block_7:get_max_moves())
      block_puzzle_1_block_8:get_sprite():set_direction(block_puzzle_1_block_8:get_max_moves())
      sol.audio.play_sound("wrong") 
      block_puzzle_1_fake_switch:set_activated(false) 
    end)
end

local block_puzzle_1_switches = 0
local goal_block_puzzle_1 = 8
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

--ENIGME DE BLOCS POUR PORTE 8
function block_puzzle_2_fake_switch:on_activated()
    sol.timer.start(500,function()
      block_puzzle_2_block_1:reset()
      block_puzzle_2_block_2:reset()
      block_puzzle_2_block_3:reset()
      block_puzzle_2_block_4:reset()
      block_puzzle_2_block_1:set_max_moves(3)
      block_puzzle_2_block_2:set_max_moves(3)
      block_puzzle_2_block_3:set_max_moves(3)
      block_puzzle_2_block_4:set_max_moves(3)
      block_puzzle_2_block_1:get_sprite():set_direction(block_puzzle_2_block_1:get_max_moves())
      block_puzzle_2_block_2:get_sprite():set_direction(block_puzzle_2_block_2:get_max_moves())
      block_puzzle_2_block_3:get_sprite():set_direction(block_puzzle_2_block_3:get_max_moves())
      block_puzzle_2_block_4:get_sprite():set_direction(block_puzzle_2_block_4:get_max_moves())
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
      auto_switch_auto_door_3:set_enabled(true)
      block_puzzle_2_fake_switch:set_enabled(false)
    end
  end
  function switch:on_inactivated()
    block_puzzle_2_switches = block_puzzle_2_switches - 1
    auto_switch_auto_door_3:set_enabled(false)
    block_puzzle_2_fake_switch:set_enabled(true)
  end
end
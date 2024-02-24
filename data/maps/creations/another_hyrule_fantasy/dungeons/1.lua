local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.text_surface.create{
  text_key = "dungeon_1001.name",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_2_back")
  map:set_doors_open("auto_door_4_back")

  --Equipement requis pour le Temple + Initialisation variables
  if destination == entree_donjon then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")

    game:set_max_life(3*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(1)
    game:get_item("equipment/shield"):set_variant(1)

    game:set_value("force",1)
    game:set_value("defense",1)

    if game:get_value("get_bow") then
      game:get_item("equipment/quiver"):set_variant(1)
      local arrows_counter = game:get_item("inventory/bow")
      arrows_counter:set_variant(1)
      arrows_counter:set_amount(30)
    end

  end

  --Upgrades si achat au magasin
  if game:get_value("labors_magic_flask_upgrade_wave_1") then game:get_item("magic_bar"):set_variant(2) end
  if game:get_value("labors_attack_boost_wave_1") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("labors_defense_boost_wave_1") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
  if game:get_value("labors_quiver_wave_1") then game:get_item("equipment/quiver"):set_variant(2) game:get_item("inventory/bow"):set_amount(50) end

  --Clé 1 obtenue
  if game:get_value("key_1001_1") then auto_chest_key_1:set_enabled(true) end
  --Clé 2 obtenue
  if game:get_value("key_1001_2") then auto_chest_key_2:set_enabled(true) end

  --Énigme blocs 1 faite
  if game:get_value("door_1001_1") then  
    auto_switch_auto_door_1:set_enabled(true)
    block_puzzle_1_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_1_switch_1:get_position()
    local x2, y2 = block_puzzle_1_switch_2:get_position()
    block_puzzle_1_block_1:set_position(x1 + 8, y1 + 13)
    block_puzzle_1_block_1:set_pushable(false)
    block_puzzle_1_block_1:set_pullable(false)
    block_puzzle_1_block_2:set_position(x2 + 8, y2 + 13)
    block_puzzle_1_block_2:set_pushable(false)
    block_puzzle_1_block_2:set_pullable(false)
  else auto_switch_auto_door_1:set_enabled(false) end

  --Carte obtenue
  if game:get_value("map_1001") then auto_chest_map:set_enabled(true) end
  --Boussole obtenue
  if game:get_value("compass_1001") then auto_chest_compass:set_enabled(true) end
  --Clé du Boss obtenue
  if game:get_value("boss_key_1001") then auto_chest_boss_key:set_enabled(true) end

  --Portes ouvertes: Combats
  if game:get_value("door_1001_2") then sensor_falling_auto_door_2_back:set_enabled(false) end
  if game:get_value("door_1001_4") then sensor_falling_auto_door_4_back:set_enabled(false) end

  --Boss
  if game:get_value("boss_1001") then 
    sensor_boss:set_enabled(false) 
    map:set_doors_open("door_boss")
    local x, y = heart_container_spot:get_position()
    map:create_pickable{
      treasure_name = "quest_items/heart_container",
      treasure_variant = 1,
      treasure_savegame_variable = "heart_container_1001",
      x = x,
      y = y,
      layer = 1
    }
  else map:set_doors_open("door_boss_1") boss:set_enabled(false) gohma:set_enabled(false) end
end

--ENIGME DE BLOCS 1
function block_puzzle_1_fake_switch:on_activated()
    sol.timer.start(500,function() 
      block_puzzle_1_block_1:reset()
      block_puzzle_1_block_2:reset()
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
      auto_switch_auto_door_1:set_enabled(true)
      block_puzzle_1_fake_switch:set_enabled(false)
    end
  end
  function switch:on_inactivated()
    block_puzzle_1_switches = block_puzzle_1_switches - 1
  end
end
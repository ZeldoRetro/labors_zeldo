local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

texte_lieu = sol.text_surface.create{
  text_key = "dungeon_10002.name",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}


--DEBUT DE LA MAP
function map:on_started(destination)

  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)

  --Equipement requis pour le Temple + Initialisation variables
  if destination == entree_donjon then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic2")

    game:set_max_life(12*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(2)
    game:set_ability("tunic", 2)
    game:get_item("equipment/sword"):set_variant(3)
    game:get_item("equipment/shield"):set_variant(2)

    game:set_value("force",3)
    game:set_value("defense",2)

    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(1)
    game:get_item("inventory/hookshot"):set_variant(1)
    game:get_item("inventory/hammer"):set_variant(1)
    game:get_item("inventory/fire_rod"):set_variant(1)
    game:get_item("inventory/magic_powder"):set_variant(1)
    if game:get_value("get_monicle_truth_10002") then game:get_item("inventory/monicle_truth"):set_variant(1) end
    game:get_item("equipment/bomb_bag"):set_variant(1)
    local bombs_counter = game:get_item("inventory/bombs_counter")
    bombs_counter:set_variant(1)
    bombs_counter:set_amount(20)
    game:get_item("equipment/quiver"):set_variant(1)
    local arrows_counter = game:get_item("inventory/bow")
    arrows_counter:set_variant(1)
    arrows_counter:set_amount(30)

  end

  --Upgrades si achat au magasin
  if game:get_value("labors_magic_flask_upgrade_wave_1") then game:get_item("magic_bar"):set_variant(2) end
  if game:get_value("labors_attack_boost_wave_1") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("labors_defense_boost_wave_1") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
  if game:get_value("labors_quiver_wave_1") then game:get_item("equipment/quiver"):set_variant(2) game:get_item("inventory/bow"):set_amount(50) end
  if game:get_value("labors_bomb_bag_wave_1") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end

  --Enemis et entités invisibles
  for entity in map:get_entities("invisible_path") do
	 entity:set_visible(false)
  end
  for entity in map:get_entities("invisible_enemy") do
  	entity:set_visible(false)
  end

  --Portes ouvertes, ennemis visibles, ...
  map:set_doors_open("door_boss_1")
  map:set_doors_open("minidoor_boss_1")
  map:set_doors_open("falling_door")
  map:set_doors_open("door_battle_back")
  map:set_doors_open("auto_door_1_back")
  map:set_entities_enabled("enemy_battle",false)
  map:set_entities_enabled("invisible_enemy_battle",false)
  map:set_entities_enabled("auto_chest",false)
  front_chest_sensor:set_enabled(false)
  --Clé 1 obtenue
  if game:get_value("key_10002_1") then auto_chest_key_1:set_enabled(true) end
  --Clé 4 obtenue
  if game:get_value("key_10002_4") then auto_chest_key_2:set_enabled(true) end
  --Porte 1 ouverte: Combat
  if game:get_value("door_103_1") then sensor_battle_2:set_enabled(false) end
  --Grande clé obtenue
  if game:get_value("bosskey_10002") then 
    sensor_battle_1:set_enabled(false) 
    map:set_entities_enabled("chest_big_key",true)
  end
  --Miniboss battu
  if game:get_value("miniboss_10002") then 
    push_miniboss_tomb_sensor:set_enabled(false) 
    tomb_push_miniboss_tomb_sensor:set_position(784, 88)
  else miniboss:set_enabled(false) end
  --Boss battu
  if game:get_value("boss_10002") then 
    push_boss_tomb_sensor:set_enabled(false) 
    tomb_push_boss_tomb_sensor:set_position(1424, 328)
    local x, y = heart_container_spot:get_position()
    map:create_pickable{
      treasure_name = "quest_items/remembrance_shard",
      treasure_variant = 4,
      treasure_savegame_variable = "heart_container_10002",
      x = x,
      y = y,
      layer = 1
    }
  else boss:set_enabled(false) end
end

--SALLES:COMBAT
function sensor_battle_2:on_activated()
  sensor_battle_2:set_enabled(false)
  map:close_doors("auto_door_1_back")
end

--MINIBOSS ACTIVE EN POUSSANT SA TOMBE
function push_miniboss_tomb_sensor:on_activated_repeat()
  if game:get_hero():get_state() == "pushing" and hero:get_direction() == 1 then
    push_miniboss_tomb_sensor:set_enabled(false)
    sol.audio.play_sound("hero_pushes")
      local tomb_x,tomb_y = map:get_entity("tomb_push_miniboss_tomb_sensor"):get_position()
      local i = 0
      sol.timer.start(map,50,function()
        i = i + 1
        tomb_y = tomb_y - 1
        map:get_entity("tomb_push_miniboss_tomb_sensor"):set_position(tomb_x, tomb_y)
        if i < 16 then return true end
        sol.audio.play_music("none")
        miniboss:set_enabled(true)
        game:start_dialog("LABORS.tott.ancient_catacomb.miniboss_intro",function()
          map:close_doors("minidoor_boss")
          sol.audio.play_music("miniboss")
        end)
      end)
  end
end
--MINIBOSS: GRAND SPECTRE
if miniboss ~= nil then
 function miniboss:on_dying()
  miniboss:get_sprite():set_ignore_suspend(true)
  game:start_dialog("LABORS.tott.ancient_catacomb.miniboss_end")
  local door_x, door_y = map:get_entity("minidoor_boss_2"):get_position()
  sol.audio.play_music("none")
  hero:freeze()
  sol.timer.start(6000,function()
    sol.audio.play_sound("correct")
    map:move_camera(door_x,door_y,256,function() 
      map:open_doors("minidoor_boss")
      hero:unfreeze()
      sol.audio.play_music(music_map)
    end)
  end)
 end
end

--PORTES INVISIBLES
auto_separator_14:register_event("on_activating", function(separator, direction4)
  if direction4 == 3 then
    sol.audio.play_sound("secret")
  end
end)
auto_separator_10:register_event("on_activating", function(separator, direction4)
  if direction4 == 0 then
    sol.audio.play_sound("secret")
  end
end)
function secret_separator:on_activating(direction4)
  if direction4 == 2 then sol.audio.play_sound("secret") end
end

--GRANDE CLE: BATAILLE
function sensor_battle_1:on_activated()
  map:close_doors("door_battle_back_1")
  sol.audio.play_music("none")
  hero:freeze()
  sol.timer.start(1000,function()
    hero:unfreeze()
    sol.audio.play_music("battle")
    sensor_battle_1:set_enabled(false)
    map:set_entities_enabled("enemy_battle_1_1",true)
  end)   
end
for enemy in map:get_entities("enemy_battle_1_1") do
  enemy.on_dead = function()
    if not map:has_entities("enemy_battle_1_1") then
      sol.audio.play_sound("correct")
		  map:set_entities_enabled("enemy_battle_1_2",true)
    end
  end
end
for enemy in map:get_entities("enemy_battle_1_2") do
  enemy.on_dead = function()
    if not map:has_entities("enemy_battle_1_2") then
      sol.audio.play_sound("correct")
		  map:set_entities_enabled("invisible_enemy_battle_1_3",true)
    end
  end
end
for enemy in map:get_entities("invisible_enemy_battle_1_3") do
  enemy:set_visible(false)
  enemy.on_dead = function()
    if not map:has_entities("invisible_enemy_battle_1_3") then
      hero:freeze()
      game:set_pause_allowed(false)
      sol.audio.play_sound("correct") 
      sol.audio.play_music("none")
      sol.timer.start(1000,function()
        map:open_doors("door_battle_back")
        sol.audio.play_sound("chest_appears")
        chest_appears_effect_3:set_enabled(true)
        sol.timer.start(3000,function()
          front_chest_sensor:set_enabled(true)
          map:set_entities_enabled("chest_big_key",true)
          chest_big_key_1:get_sprite():fade_in(100,function()
            front_chest_sensor:set_enabled(false)
            sol.audio.play_sound("secret")
            chest_appears_effect_3:set_enabled(false)
            hero:unfreeze()
            game:set_pause_allowed(true)
            sol.audio.play_music(music_map)
          end)
        end)
      end)	
    end
  end
end
--Link repoussé si dans la zone du coffre
function front_chest_sensor:on_activated() hero:set_position(160,621) end

--BOSS ACTIVE EN POUSSANT SA TOMBE
function push_boss_tomb_sensor:on_activated_repeat()
  if game:get_hero():get_state() == "pushing" and hero:get_direction() == 1 then
    push_boss_tomb_sensor:set_enabled(false)
    sol.audio.play_sound("hero_pushes")
      local tomb_x,tomb_y = map:get_entity("tomb_push_boss_tomb_sensor"):get_position()
      local i = 0
      sol.timer.start(map,50,function()
        i = i + 1
        tomb_y = tomb_y - 1
        map:get_entity("tomb_push_boss_tomb_sensor"):set_position(tomb_x, tomb_y)
        if i < 16 then return true end
        sol.audio.play_music("none")
        boss:set_enabled(true)
        game:start_dialog("LABORS.tott.ancient_catacomb.boss_intro",function()
          map:close_doors("door_boss")
          sol.audio.play_music("miniboss_2")
        end)
      end)
  end
end
--BOSS
if boss ~= nil then
 function boss:on_dying()
  boss:get_sprite():set_ignore_suspend(true)
  game:start_dialog("LABORS.tott.ancient_catacomb.boss_end")
  local door_x, door_y = map:get_entity("door_boss_2"):get_position()
  sol.audio.play_music("none")
  hero:freeze()
  sol.timer.start(6000,function()
    sol.audio.play_sound("correct")
    map:move_camera(door_x,door_y,256,function() 
      map:open_doors("door_boss_2") 
      hero:unfreeze()
      sol.audio.play_music("after_boss")
      local x, y = heart_container_spot:get_position()
      map:create_pickable{
        treasure_name = "quest_items/remembrance_shard",
        treasure_variant = 4,
        treasure_savegame_variable = "heart_container_10002",
        x = x,
        y = y,
        layer = 1
      }
    end)
  end)
 end
end

local lit_torch = 0
for torch in map:get_entities("timed_torch_") do
  torch:set_duration(5000)
  function torch:on_lit() 
    lit_torch = lit_torch + 1
    sol.timer.start(5000,function() 
      lit_torch = lit_torch - 1
    end)
  end
end
function map:on_update()
  if not game:get_value("miniboss_10002") then
    if lit_torch == 0 then
      miniboss:set_invincible()
      miniboss:set_visible(false)
      miniboss:set_can_attack(false)
    else
      miniboss:set_visible(true)
      miniboss:set_can_attack(true)
      miniboss:set_attack_consequence("sword",1)
    end
  end
  if not game:get_value("boss_10002") then
    if not game:get_value("monicle_active") then
      boss:set_invincible()
      boss:set_visible(false)
      boss:set_can_attack(false)
    else
      boss:set_visible(true)
      boss:set_can_attack(true)
      boss:set_attack_consequence("sword",1)
    end
  end
end

--STELE DE FIN: CHANT DE L'OMBRE SI LIVRE DE MUDORA
function stele_chant:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.ancient_catacomb.final_sign",function()
    if game:get_value("get_trophy_10002") then return
    else hero:start_treasure("quest_items/trophy_labors_tott",1,"get_trophy_10002") end
  end)
end
local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)

  -- Initialisations variables et équipement pour début de la Zone
  if destination == entree_donjon then
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("hero/sword1")
    hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")

    -- Stats force/défense + apparence
    game:set_max_life(5*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(1)
    game:set_value("force",1)
    game:get_item("equipment/shield"):set_variant(1)
    game:set_value("defense",1)

    -- Objets
    game:get_item("equipment/quiver"):set_variant(1)
    local arrows_counter = game:get_item("inventory/bow")
    arrows_counter:set_variant(1)
    arrows_counter:set_amount(30)
    game:get_item("equipment/flippers"):set_variant(1)
    game:set_ability("swim",1)

    -- Sac de Bombes ?
    if game:get_value("get_bomb_bag_10015") then
      game:get_item("equipment/bomb_bag"):set_variant(1)
      local bombs_counter = game:get_item("inventory/bombs_counter")
      bombs_counter:set_variant(1)
      bombs_counter:set_amount(20)
    end

    game:set_value("dungeon_10015_water_level",0)

    -- Objets permanents
    if game:get_value("labors_perma_glove_3_wave_2") then
      game:get_item("equipment/glove"):set_variant(3)
      game:set_ability("lift",3)
    end
    if game:get_value("labors_perma_lamp_wave_2") then
      game:get_item("inventory/lamp"):set_variant(1)
    end
    if game:get_value("labors_perma_boomerang_2_wave_2") then
      game:get_item("inventory/boomerang"):set_variant(2)
    end
    if game:get_value("labors_perma_monicle_truth_wave_2") then
      game:get_item("inventory/monicle_truth"):set_variant(1)
    end

    --Upgrades si achat au magasin
    if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
    if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
    if game:get_value("tott_upgrade_card_arrows_active") then game:get_item("equipment/quiver"):set_variant(2) game:get_item("inventory/bow"):set_amount(50) end
    if game:get_value("tott_upgrade_card_bombs_active") then
      if game:get_value("get_bomb_bag_10015") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
    end
  end

  -- Pas de musique près du boss
  if destination == escalier_n or destination == telep_boss_sortie or destination == escalier_boss then
    sol.audio.play_music("none")
  end

  -- Initialisation bassins (sauvegardés entre étages)
  if game:get_value("dungeon_10015_bath_1") then
    map:set_entities_enabled("bath_2_step_", false)
    map:set_entities_enabled("bath_1_step_", true)
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(false) end
  elseif game:get_value("dungeon_10015_bath_2") then
    map:set_entities_enabled("bath_1_step_", false)
    map:set_entities_enabled("bath_2_step_", true)
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(true) end
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(false) end
  end
end)

-- SWITCHES ET SYSTÈME DE BASSINS

for switch in map:get_entities("bath_2_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_1_step_3_", false)
      map:set_entities_enabled("bath_2_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_1_step_2_", false)
        map:set_entities_enabled("bath_2_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_1_step_1_", false)
          map:set_entities_enabled("bath_2_step_3_", true)
          for switch in map:get_entities("bath_1_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
          game:set_value("dungeon_10015_bath_2",true)
          game:set_value("dungeon_10015_bath_1",false)
        end)
      end)
    end)
  end
end

for switch in map:get_entities("bath_1_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_2_step_3_", false)
      map:set_entities_enabled("bath_1_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_2_step_2_", false)
        map:set_entities_enabled("bath_1_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_2_step_1_", false)
          map:set_entities_enabled("bath_1_step_3_", true)
          for switch in map:get_entities("bath_2_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
          game:set_value("dungeon_10015_bath_1",true)
          game:set_value("dungeon_10015_bath_2",false)
        end)
      end)
    end)
  end
end
local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("hero/sword1")

    -- Stats force/défense + apparence
    game:set_max_life(8*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)

    -- Épée ?
    if game:get_value("get_sword_10017") then 
      game:get_item("equipment/sword"):set_variant(1)
      game:set_value("force",1)
    else
      game:get_item("equipment/sword"):set_variant(0)
      game:set_value("force",0)
    end

    -- Bouclier ?
    if game:get_value("get_shield_10017") then 
      hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")
      game:get_item("equipment/shield"):set_variant(1)
      game:set_value("defense",1)
    else
      game:get_item("equipment/shield"):set_variant(0)
      game:set_value("defense",0)
    end

    -- Arc ?
    if game:get_value("get_bow_10017") then
      game:get_item("equipment/quiver"):set_variant(1)
      local arrows_counter = game:get_item("inventory/bow")
      arrows_counter:set_variant(1)
      arrows_counter:set_amount(30)
    end

    -- Palmes ?
    if game:get_value("get_flippers_10017") then
      game:get_item("equipment/flippers"):set_variant(1)
      game:set_ability("swim",1)
    end

    -- Sac de Bombes ?
    if game:get_value("get_bomb_bag_10017") then
      game:get_item("equipment/bomb_bag"):set_variant(1)
      local bombs_counter = game:get_item("inventory/bombs_counter")
      bombs_counter:set_variant(1)
      bombs_counter:set_amount(20)
    end

    -- Gants de Puissance ?
    if game:get_value("get_glove_10017") then
      game:get_item("equipment/glove"):set_variant(2)
      game:set_ability("lift",2)
    end

    -- Boomerang ?
    if game:get_value("get_boomerang_10017") then
      game:get_item("inventory/boomerang"):set_variant(1)
    end

    -- Lanterne ?
    if game:get_value("get_lamp_10017") then
      game:get_item("inventory/lamp"):set_variant(1)
    end

    game:set_value("dungeon_10017_initialized", true)

    -- Objets permanents
    if game:get_value("labors_perma_glove_3_wave_2") and game:get_value("get_glove_10017") then
      game:get_item("equipment/glove"):set_variant(3)
      game:set_ability("lift",3)
    end
    if game:get_value("labors_perma_boomerang_2_wave_2") and game:get_value("get_boomerang_10017") then
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
      if game:get_value("get_bomb_bag_10017") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
    end
  end

  -- Niveau de l'eau et escaliers
  if game:get_value("dungeon_10017_water_level") == 1 then 
    map:set_entities_enabled("water_low",false)
  end
end)
local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic3")
    hero:set_sword_sprite_id("hero/sword4")
    if game:get_value("get_shield_10018") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield3")
    else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2") end

    -- Stats force/défense + apparence
    game:set_max_life(16*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(3)
    game:get_item("equipment/sword"):set_variant(4)
    game:set_value("force",4)
    game:get_item("equipment/shield"):set_variant(1)
    if game:get_value("get_shield_10018") then game:set_value("defense",4) else game:set_value("defense",3) end

    -- Objets
    game:get_item("equipment/quiver"):set_variant(1)
    local arrows_counter = game:get_item("inventory/bow_light")
    arrows_counter:set_variant(1)
    arrows_counter:set_amount(30)
    game:get_item("equipment/flippers"):set_variant(1)
    game:set_ability("swim",1)
    game:get_item("equipment/bomb_bag"):set_variant(1)
    local bombs_counter = game:get_item("inventory/bombs_counter")
    bombs_counter:set_variant(1)
    bombs_counter:set_amount(20)
    game:get_item("equipment/glove"):set_variant(2)
    game:set_ability("lift",2)
    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(1)

    -- Objets permanents
    if game:get_value("labors_perma_glove_3_wave_2") then
      game:get_item("equipment/glove"):set_variant(3)
      game:set_ability("lift",3)
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
    if game:get_value("tott_upgrade_card_bombs_active") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
  end
end)
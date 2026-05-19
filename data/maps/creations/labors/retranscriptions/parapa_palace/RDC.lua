local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)

  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:set_sword_sprite_id("npc/playing_character/link_alttp/sword1")
  hero:set_shield_sprite_id("npc/playing_character/link_alttp/shield1")

  -- Valeurs et équipement donnés pour la Zone
  if destination == entree_donjon then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    -- Stats force/défense + apparence
    game:set_max_life(4*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)

    -- Objets
    game:get_item("equipment/sword"):set_variant(7)
    game:set_value("force",1)
    game:get_item("equipment/shield"):set_variant(1)
    game:set_value("defense",1)
    game:get_item("equipment/bomb_bag"):set_variant(1)
    local bombs_counter = game:get_item("inventory/bombs_counter")
    bombs_counter:set_variant(1)
    bombs_counter:set_amount(20)

    -- Lampe ?
    if game:get_value("get_lamp_10022") then
      game:get_item("inventory/lamp"):set_variant(1)
    end

    --Upgrades si achat au magasin
    if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
    if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
    if game:get_value("tott_upgrade_card_arrows_active") then game:get_item("equipment/quiver"):set_variant(2) game:get_item("inventory/bow"):set_amount(50) end
    if game:get_value("tott_upgrade_card_bombs_active") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
  end
end)
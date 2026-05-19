local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- RESET STATUT

  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")
  hero:set_sword_sprite_id("npc/playing_character/eldran_sword1")
  hero:set_shield_sprite_id("npc/playing_character/eldran_shield1")

  -- Stats force/défense + apparence
  game:set_max_life(20*4)
  game:set_life(game:get_max_life())
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  game:get_item("equipment/tunic"):set_variant(1)
  game:set_ability("tunic",1)
  game:get_item("equipment/sword"):set_variant(6)
  game:set_ability("shield",0)
  game:get_item("equipment/shield"):set_variant(0)
  game:set_value("force",1)
  game:set_value("defense",1)

  -- Objets
  game:get_item("inventory/lamp"):set_variant(0)
  game:get_item("inventory/boomerang"):set_variant(0)
  game:get_item("inventory/hookshot"):set_variant(0)
  game:get_item("inventory/hammer"):set_variant(0)
  game:get_item("inventory/fire_rod"):set_variant(0)
  game:get_item("inventory/ice_rod"):set_variant(0)
  game:get_item("inventory/ocarina"):set_variant(0)
  game:get_item("inventory/magic_powder"):set_variant(0)
  game:get_item("inventory/monicle_truth"):set_variant(0)
  game:get_item("equipment/bomb_bag"):set_variant(0)
  game:get_item("equipment/flippers"):set_variant(0)
  game:set_ability("swim",0)
  game:get_item("equipment/glove"):set_variant(0)
  game:set_ability("lift",1)
  local bombs_counter = game:get_item("inventory/bombs_counter")
  bombs_counter:set_variant(0)
  bombs_counter:set_amount(0)
  game:get_item("equipment/quiver"):set_variant(0)
  local arrows_counter = game:get_item("inventory/bow")
  arrows_counter:set_variant(0)
  arrows_counter:set_amount(0)
  game:get_item("inventory/bow_light"):set_variant(0)
  game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)

  -- Objets PLAYER
  if game:get_value("zeldo_wave_1_defeated") then game:get_item("equipment/sword_PLAYER"):set_variant(1) end
  if game:get_value("zeldo_wave_2_defeated") then game:get_item("inventory/bow_PLAYER"):set_variant(1) end

  --Upgrades si achat au magasin
  if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end

end)

-- INIT DRAW CADRES + ENLEVER OBJETS PLAYER QUAND VERS ZONE DE TRAVAUX
map:register_event("on_finished",function(map)
  function sol.video:on_draw(screen) end

  local hero_x, hero_y = map:get_hero():get_position()
  if hero_x < 776 or hero_x > 824 then
    game:get_item("equipment/sword_PLAYER"):set_variant(0)
    game:get_item("inventory/bow_PLAYER"):set_variant(0)
  end
end)
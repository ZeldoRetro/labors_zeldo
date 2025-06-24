local map = ...
local game = map:get_game()

--BACKGROUND ARBRES
local trees = sol.surface.create("backgrounds/trees.png")

map:register_event("on_draw",function(map,dst_surface)
  trees:draw(dst_surface)
end)

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")

    -- Stats force/défense + apparence
    game:set_max_life(10*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(5)
    game:set_value("force",2)
    game:get_item("equipment/shield"):set_variant(1)
    game:set_value("defense",1)

    -- Objets
    game:get_item("equipment/quiver"):set_variant(1)
    local arrows_counter = game:get_item("inventory/bow")
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
    game:get_item("inventory/boomerang"):set_variant(1)

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
    if game:get_value("tott_upgrade_card_bombs_active") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
  elseif destination == sortie_temple or destination == farore_shrine then
    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("hero/sword1")
    if game:get_value("get_shield_10011") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end
  end
end)

-- PORTE DE BOIS: BESOIN DE LA CLÉ DE BOIS POUR OUVRIR
function wooden_door_npc:on_interaction()
  if game:get_value("get_wooden_key_10011") then
    sol.audio.play_sound("secret")
    sol.audio.play_sound("door_open")
    map:set_entities_enabled("wooden_door", false)
    game:set_value("wooden_door_10011_opened", true)
  else sol.audio.play_sound("wrong") game:start_dialog("door.closed.wooden_door") end
end

-- PORTE DE BOIS 2: BESOIN DE LA CLÉ DE BOIS POUR OUVRIR
function wooden_door_npc_2:on_interaction()
  if game:get_value("get_wooden_key_10011") then
    sol.audio.play_sound("secret")
    sol.audio.play_sound("door_open")
    map:set_entities_enabled("wooden_door", false)
    game:set_value("wooden_door_10011_opened_2", true)
  else sol.audio.play_sound("wrong") game:start_dialog("door.closed.wooden_door") end
end
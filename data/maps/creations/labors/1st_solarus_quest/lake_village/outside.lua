local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Modèle LINK
  if destination == nayru_shrine or destination == vortex_field then
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    if game:get_value("get_shield_10016") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2")
    else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end
  else
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("hero/sword1")
    hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")    
  end

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    -- Stats force/défense + apparence
    game:set_max_life(4*4)
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

    -- Échanges Village du Lac
    if game:get_value("get_iron_key_10012") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)
    elseif game:get_value("get_trade_10012_5") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(5)
    elseif game:get_value("door_10012_library") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)
    elseif game:get_value("get_trade_10012_4") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(4)
    elseif game:get_value("get_trade_10012_3") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(3)
    elseif game:get_value("get_trade_10012_2") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(2)
    elseif game:get_value("get_trade_10012_1") then game:get_item("inventory/echange_1st_solarus_quest"):set_variant(1) end

    -- Palmes ?
    if game:get_value("get_flippers_10012") then
      game:get_item("equipment/flippers"):set_variant(1)
      game:set_ability("swim",1)
    end

    -- Objets permanents
    if game:get_value("labors_perma_bombs_wave_2") then
      game:get_item("equipment/bomb_bag"):set_variant(1)
      local bombs_counter = game:get_item("inventory/bombs_counter")
      bombs_counter:set_variant(1)
      bombs_counter:set_amount(20)
    end
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
      if game:get_value("labors_perma_bombs_wave_2") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end
    end
  end

  -- Flèches et bombes en vente
  if game:get_value("labors_perma_bombs_wave_2") and (game:get_value("day") or game:get_value("twilight")) then map:set_entities_enabled("day_entity_bombs", true) end

  -- Miroir acheté au Marchand itinérant
  if game:get_value("get_trade_10012_1") and (game:get_value("day") or game:get_value("twilight")) then day_entity_hearts:set_enabled(true) end
end)

-- MARCHAND AMBULANT: BIENVENUE ET AUTRES
function day_entity_shop_welcome:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_merchant")
end

-- Échange : Pierre contre Livre
function day_entity_trade_npc:on_interaction()
  if game:get_value("get_trade_10012_4") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.4-pierre.done")
  else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.4-pierre.default") end
end

function day_entity_trade_npc:on_interaction_item(item)
  if item == game:get_item("inventory/echange_1st_solarus_quest") and item:get_variant() == 3 then
    game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.4-pierre.question",function(answer)
      if answer == 1 then
        game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.4-pierre.answer_yes",function()
          hero:start_treasure("inventory/echange_1st_solarus_quest",4,"get_trade_10012_4")
        end)
      else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.4-pierre.answer_no") end
    end)
  end
end

function night_entity_sign:on_interaction()
  game:set_dialog_style("wood")
  game:start_dialog("sign.labors.1st_solarus_quest.merchant_closed")
end

-- PORTE DE FER : BESOIN DE LA CLÉ DE FER POUR OUVRIR
function iron_door_npc:on_interaction()
  if game:get_value("get_iron_key_10012") then
    sol.audio.play_sound("secret")
    sol.audio.play_sound("door_open")
    map:set_entities_enabled("iron_door", false)
    game:set_value("iron_door_10012_opened", true)
  else sol.audio.play_sound("wrong") game:start_dialog("door.closed.iron_door") end
end
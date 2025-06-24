local map = ...
local game = map:get_game()

--TEMPS SOMBRE LORS DE LA ZONE DU CHÂTEAU
local dark_img = sol.surface.create(320,240)
dark_img:set_opacity(192)
dark_img:fill_color({0, 0, 0})
local dark = false

map:register_event("on_draw",function(map,dst_surface)
  if dark then dark_img:draw(dst_surface) end
end)

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Modèle LINK
  if destination ~= lost_woods and destination ~= house_merchant then
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    if game:get_value("get_shield_10016") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2")
    else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end
  end

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    -- Stats force/défense + apparence
    game:set_max_life(10*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(5)
    game:set_value("force",2)
    game:get_item("equipment/shield"):set_variant(1)
    if game:get_value("get_shield_10016") then game:set_value("defense",2) else game:set_value("defense",1) end

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

    -- Boomerang 2 ?
    if game:get_value("get_boomerang_10016") then game:get_item("inventory/boomerang"):set_variant(2) else game:get_item("inventory/boomerang"):set_variant(1) end

    -- Objets permanents
    if game:get_value("labors_perma_glove_3_wave_2") then
      game:get_item("equipment/glove"):set_variant(3)
      game:set_ability("lift",3)
    end
    if game:get_value("labors_perma_lamp_wave_2") then
      game:get_item("inventory/lamp"):set_variant(1)
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

  -- Joue ou non la musique de la citadelle si arrivée de nuit
  if game:get_value("night") or game:get_value("dawn") then
    map:set_entities_enabled("play_music_sensor", false)
  end

  -- Musique de citadelle si sortie de maison (sauf la nuit)
  if destination == house_1 or destination == house_2 or destination == house_2_2 or destination == house_3 or destination == house_4 or destination == inn or destination == inn_2 or destination == shop then
    if game:get_value("night") or game:get_value("dawn") then return end
    sol.audio.play_music("creations/labors/1st_solarus_quest/castle_town")
  end

  -- Certains évènements surviennent si on est en train de faire la Zone du Château
  if game:get_value("dungeon_10017_initialized") then

    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("hero/sword1")
    if game:get_value("get_shield_10017") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end
      
    sol.audio.play_music("creations/labors/1st_solarus_quest/rain")
    map:set_entities_enabled("enemy",true)
    map:set_entities_enabled("electric_barrier",true)
    map:set_entities_enabled("soldier",false)
    map:set_entities_enabled("castle_barrier",true)
    map:set_entities_enabled("tp_castle_alt",true)
    map:set_entities_enabled("tp_castle_normal",false)
    dark = true
    rain:set_enabled(true)
    sol.timer.start(map, math.random(5000,10000), function()
      sol.audio.play_sound("thunder")
      dark = false sol.timer.start(map, 100, function() dark = true end)
      return true
    end)
  end

end)

-- MARCHAND AMBULANT: BIENVENUE ET AUTRES
function day_entity_shop_welcome:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_merchant")
end

--TOMBE A POUSSER POUR SECRET
function grave_block:on_moving()
  hero:freeze()
  sol.audio.play_sound("hero_pushes")

  local m = sol.movement.create("straight")
  m:set_speed(32)
  m:set_angle(math.pi / 2)
  m:set_max_distance(16)

  m:start(grave_block,function()
    sol.audio.play_sound("secret")
    grave_tp:set_enabled(true)
    grave_ground:set_enabled(false)
    hero:unfreeze()
  end)
end

-- PORTE DE FER : BESOIN DE LA CLÉ DE FER POUR OUVRIR
function iron_door_npc:on_interaction()
  if game:get_value("get_iron_key_10012") then
    sol.audio.play_sound("secret")
    sol.audio.play_sound("door_open")
    map:set_entities_enabled("iron_door", false)
    game:set_value("iron_door_10016_opened", true)
  else sol.audio.play_sound("wrong") game:start_dialog("door.closed.iron_door") end
end

-- COFFRES VIDES
function chest_empty_1:on_opened()
    sol.audio.play_sound("treasure_bad")
	game:start_dialog("_empty_chest")
	hero:unfreeze()
end
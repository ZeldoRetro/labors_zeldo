local map = ...
local game = map:get_game()

texte_lieu = sol.text_surface.create{
  text_key = "location.tott.hylia_waterfall",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

--DEBUT DE LA MAP
function map:on_started(destination)

  --Equipement requis + Initialisation variables
  if destination == start then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")

    game:set_max_life(10*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(2)
    game:set_ability("tunic", 2)
    game:get_item("equipment/sword"):set_variant(2)
    game:get_item("equipment/shield"):set_variant(2)

    game:set_value("force",2)
    game:set_value("defense",2)

    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(2)
    game:get_item("inventory/hookshot"):set_variant(1)
    game:get_item("equipment/flippers"):set_variant(1)
    game:set_ability("swim",1)
    game:get_item("equipment/glove"):set_variant(2)
    game:set_ability("lift",2)
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

  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    sol.audio.play_music("creations/labors/tott/field")
    map:set_entities_enabled("night_entity",false)
    map:set_entities_enabled("fairy_power_fragment",false)
    map:set_entities_enabled("day_entity",true)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    sol.audio.play_music("creations/labors/tott/field_night")
    map:set_entities_enabled("night_entity",true)
    map:set_entities_enabled("day_entity",false)
  end
end
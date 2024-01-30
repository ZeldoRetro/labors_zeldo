local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.text_surface.create{
  text_key = "dungeon_10004.name",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(40)
heat:fill_color({255,40,0})

map:register_event("on_draw",function(map,dst_surface)
  heat:draw(dst_surface)
end)


--DEBUT DE LA MAP
function map:on_started(destination)

  --Equipement requis pour le Temple + Initialisation variables
  if destination == entree_donjon then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")

    game:set_max_life(8*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(2)
    game:get_item("equipment/shield"):set_variant(2)

    game:set_value("force",2)
    game:set_value("defense",1)

    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(1)
    if game:get_value("get_fire_rod_10004") then game:get_item("inventory/fire_rod"):set_variant(1) end
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

  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)

  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

  --Clé 1 obtenue
  if game:get_value("key_10004_1") then auto_chest_key_1:set_enabled(true) end

  --Miniboss vaincu
  map:set_entities_enabled("telep_miniboss",false)
  if game:get_value("miniboss_10004") then map:set_entities_enabled("telep_miniboss",true) end

end
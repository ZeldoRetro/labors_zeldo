local map = ...
local game = map:get_game()

--TEMPS SOMBRE LORS DE L'ASSAUT DE GANON
local dark_img = sol.surface.create(320,240)
dark_img:set_opacity(160)
dark_img:fill_color({0, 0, 0})

map:register_event("on_draw",function(map,dst_surface)
  dark_img:draw(dst_surface)
end)

--Modèle LINK
hero:set_tunic_sprite_id("hero/tunic1")
hero:set_sword_sprite_id("hero/sword2")
hero:set_shield_sprite_id("hero/shield1")

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- Valeurs et équipement donnés pour la Zone
  if destination == start then

    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)

    -- Stats force/défense + apparence
    game:set_max_life(8*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(2)
    game:set_value("force",2)
    game:get_item("equipment/shield"):set_variant(1)
    game:set_value("defense",1)

    -- Objets
    game:get_item("equipment/flippers"):set_variant(1)
    game:set_ability("swim",1)
    game:get_item("equipment/glove"):set_variant(1)
    game:set_ability("lift",1)
    game:get_item("inventory/boomerang"):set_variant(1)
    game:get_item("inventory/lamp"):set_variant(1)

    --Upgrades si achat au magasin
    if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
    if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
  end

end)
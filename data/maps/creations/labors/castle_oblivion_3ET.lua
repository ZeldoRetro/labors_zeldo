local map = ...
local game = map:get_game()

local light_img = sol.surface.create(432,240)
light_img:fill_color({255, 255, 255})
local light = false

map:register_event("on_draw",function(map,dst_surface)
  if light then light_img:draw(dst_surface) end
end)

map:register_event("on_started",function(map,destination)

  -- RESET DES UPGRADES : CHANGEMENT DE VAGUE
  if destination == escalier_n or destination == escalier_s then
      if game:get_value("labors_casualization_wave_3") then game:get_item("upgrade_cards/tott_casual"):set_variant(2)
      else game:get_item("upgrade_cards/tott_casual"):set_variant(0)end
      if game:get_value("labors_quiver_wave_3") then game:get_item("upgrade_cards/tott_arrows"):set_variant(1)
      else game:get_item("upgrade_cards/tott_arrows"):set_variant(0)end
      if game:get_value("labors_attack_boost_wave_3") then game:get_item("upgrade_cards/tott_attack"):set_variant(1)
      else game:get_item("upgrade_cards/tott_attack"):set_variant(0) end
      if game:get_value("labors_magic_flask_upgrade_wave_3") then game:get_item("upgrade_cards/tott_magic"):set_variant(1)
      else game:get_item("upgrade_cards/tott_magic"):set_variant(0) end
      if game:get_value("labors_bomb_bag_wave_3") then game:get_item("upgrade_cards/tott_bombs"):set_variant(1)
      else game:get_item("upgrade_cards/tott_bombs"):set_variant(0) end
      if game:get_value("labors_defense_boost_wave_3") then game:get_item("upgrade_cards/tott_defence"):set_variant(1)
      else game:get_item("upgrade_cards/tott_defence"):set_variant(0) end
  end 

  game:set_value("force",1)
  game:set_value("defense",1)

  --Upgrades si achat au magasin
  if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
end)
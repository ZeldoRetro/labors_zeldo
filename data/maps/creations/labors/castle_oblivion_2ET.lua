local map = ...
local game = map:get_game()

map:register_event("on_started",function(map,destination)

  -- RESET DES UPGRADES : CHANGEMENT DE VAGUE
  if destination == escalier_n or destination == escalier_s then
      if game:get_value("labors_casualization_wave_2") then game:get_item("upgrade_cards/tott_casual"):set_variant(2)
      else game:get_item("upgrade_cards/tott_casual"):set_variant(0)end
      if game:get_value("labors_quiver_wave_2") then game:get_item("upgrade_cards/tott_arrows"):set_variant(1)
      else game:get_item("upgrade_cards/tott_arrows"):set_variant(0)end
      if game:get_value("labors_attack_boost_wave_2") then game:get_item("upgrade_cards/tott_attack"):set_variant(1)
      else game:get_item("upgrade_cards/tott_attack"):set_variant(0) end
      if game:get_value("labors_magic_flask_upgrade_wave_2") then game:get_item("upgrade_cards/tott_magic"):set_variant(1)
      else game:get_item("upgrade_cards/tott_magic"):set_variant(0) end
      if game:get_value("labors_bomb_bag_wave_2") then game:get_item("upgrade_cards/tott_bombs"):set_variant(1)
      else game:get_item("upgrade_cards/tott_bombs"):set_variant(0) end
      if game:get_value("labors_defense_boost_wave_2") then game:get_item("upgrade_cards/tott_defence"):set_variant(1)
      else game:get_item("upgrade_cards/tott_defence"):set_variant(0) end
  end 

  game:set_value("force",1)
  game:set_value("defense",1)

  --Upgrades si achat au magasin
  if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
end)

-- ZELDO A LA FIN DE L'ÉTAGE : FIN DE LA VAGUE
function sensor_wave_end:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.timer.start(map,1000,function()
    zeldo:get_sprite():set_direction(3)
    sol.timer.start(map,500,function()
      game:set_dialog_position("bottom")
      game:start_dialog("LABORS.zeldo_wave_2.end_floor",function()
        local sprite = zeldo:get_sprite()
        local i = 0
        sol.audio.play_sound("laser")
        sol.timer.start(map, 20, function()
          i = i + 5
          sprite:set_scale(1 - (i / 100), 1 + (i / 100))
          if i < 100 then return true
          else
            game:set_dialog_position("auto")
            game:set_life(game:get_max_life())
            zeldo:set_enabled(false)
            sol.audio.play_music("ending",false)
            hero:teleport("cutscenes/ending_wave_2")
          end
        end)
      end)
    end)
  end)
end
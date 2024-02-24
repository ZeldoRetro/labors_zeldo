local map = ...
local game = map:get_game()

function map:on_started()

  --Palmes achetées
  if game:get_value("get_flippers_10006") then flippers:set_enabled(false) trophy:set_enabled(true) end
  --Trophée acheté
  if game:get_value("get_trophy_10006") then trophy:set_enabled(false) end
  --Palmes achetées
  if game:get_value("hp_9_10006") then heart_piece:set_enabled(false) end
  --Palmes achetées
  if game:get_value("pm_4_10006") then magic_flask_blue:set_enabled(false) end
  --Palmes achetées
  if game:get_value("get_zora_scale_1_10006") then zora_scale:set_enabled(false) end
end

--DIALOGUE DE BIENVENUE DU MARCHAND
function trigger_dialog:on_activated() 
  self:set_enabled(false)
  sol.audio.play_sound("beedle_oooh")
  game:start_dialog("shop.souvenir.welcome") 
end

--ARTICLES DU MAGASIN DE SOUVENIR
--PALMES
function flippers:on_interaction()
  game:start_dialog("shop.souvenir.flippers",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/shell"):get_amount() >= 2 then
        game:get_item("quest_items/shell"):remove_amount(2)
        flippers:set_enabled(false)
        hero:start_treasure("equipment/flippers",1,"get_flippers_10006",function()
          sol.audio.play_sound("beedle_thankyou")
        end)
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shell")
      end
    end
  end)
end
--TROPHEE
function trophy:on_interaction()
  game:start_dialog("shop.souvenir.trophy",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/shell"):get_amount() >= 5 then
        game:get_item("quest_items/shell"):remove_amount(5)
        trophy:set_enabled(false)
        hero:start_treasure("quest_items/trophy_labors_tott",1,"get_trophy_10006",function()
          sol.audio.play_sound("beedle_thankyou")
        end)
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shell")
      end
    end
  end)
end
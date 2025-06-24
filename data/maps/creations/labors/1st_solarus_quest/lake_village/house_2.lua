local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  if game:get_value("get_trade_10012_3") then trade_npc:get_sprite():set_animation("stopped") else trade_npc:get_sprite():set_animation("broom_broken") end
end)

-- Échange : Balai contre Pierre
function trade_npc:on_interaction()
  if game:get_value("get_trade_10012_3") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.3-balai.done")
  else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.3-balai.default") end
end

function trade_npc:on_interaction_item(item)
  if item == game:get_item("inventory/echange_1st_solarus_quest") and item:get_variant() == 2 then
    game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.3-balai.question",function(answer)
      if answer == 1 then
        game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.3-balai.answer_yes",function()
          hero:start_treasure("inventory/echange_1st_solarus_quest",3,"get_trade_10012_3")
          trade_npc:get_sprite():set_animation("stopped")
        end)
      else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.3-balai.answer_no") end
    end)
  end
end
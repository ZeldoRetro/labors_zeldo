local map = ...
local game = map:get_game()

-- Échange : Miroir contre Balai
function trade_npc:on_interaction()
  if game:get_value("get_trade_10012_2") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.2-miroir.done")
  else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.2-miroir.default") end
end

function trade_npc:on_interaction_item(item)
  if item == game:get_item("inventory/echange_1st_solarus_quest") and item:get_variant() == 1 then
    game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.2-miroir.question",function(answer)
      if answer == 1 then
        game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.2-miroir.answer_yes",function()
          hero:start_treasure("inventory/echange_1st_solarus_quest",2,"get_trade_10012_2")
        end)
      else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.2-miroir.answer_no") end
    end)
  end
end
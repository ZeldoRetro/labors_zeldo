local map = ...
local game = map:get_game()

-- Échange : Collier contre Clé de fer
function trade_npc:on_interaction()
  if game:get_value("get_iron_key_10012") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.done")
  elseif game:get_value("blue_sage_10012_1st_time") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.default_2")
  else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.default") game:set_value("blue_sage_10012_1st_time", true) end
end

function trade_npc:on_interaction_item(item)
  if item == game:get_item("inventory/echange_1st_solarus_quest") and item:get_variant() == 5 then
    game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.question",function(answer)
      if answer == 1 then
        game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.answer_yes",function()
          hero:start_treasure("quest_items/iron_key_1st_solarus_quest",1,"get_iron_key_10012")
          game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)
        end)
      else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.6-collier.answer_no") end
    end)
  end
end
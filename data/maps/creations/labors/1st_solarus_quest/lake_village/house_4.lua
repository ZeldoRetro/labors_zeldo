local map = ...
local game = map:get_game()

-- Échange : Livre contre Collier
function trade_npc:on_interaction()
  if game:get_value("door_10012_library") then game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.5-livre.done")
  else game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.5-livre.default") end
end

function trade_npc:on_interaction_item(item)
  if item == game:get_item("inventory/echange_1st_solarus_quest") and item:get_variant() == 4 then
    game:start_dialog("LABORS.1st_solarus_quest.lake_village.echange.5-livre.question",function(answer)
      if answer == 1 then
        sol.audio.play_sound("switch")
        library_missing_book:set_enabled(false)
        game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)
        auto_switch_auto_door_1:on_activated()
      end
    end)
  end
end

-- ACTIVER SWITCH DANS BIBLIO POUR SECRET
function npc_switch:on_interaction()
  sol.audio.play_sound("switch")
  if not game:get_value("dungeon_10012_switch_library_1") then library_switch_1:on_activated() end
end
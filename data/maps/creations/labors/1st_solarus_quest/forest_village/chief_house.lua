local map = ...
local game = map:get_game()

-- SARIA EST SAUVÉE: SAGE NOUS REMERCIE ET OUVRE ACCÈS VERS LES BOIS
map:register_event("on_opening_transition_finished",function(map, destination)
    if destination == front_chief then
        game:start_dialog("LABORS.forest_village.saria_quest.chief_saria_saved",function()
            auto_switch_auto_door_4:on_activated()
        end)
    end
end)

map:register_event("on_started",function(map, destination)
    if destination == front_chief then
        saria:set_enabled(true)
    end
end)

-- DIALOGUES AVEC LE SAGE
function chief:on_interaction()
    if game:get_value("door_10019_4") then
        game:start_dialog("LABORS.forest_village.saria_quest.chief_after_save")
    else
        game:start_dialog("LABORS.forest_village.saria_quest.chief_default")
    end
end
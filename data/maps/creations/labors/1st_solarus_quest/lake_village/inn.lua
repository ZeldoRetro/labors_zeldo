local map = ...
game = map:get_game()


-- HOMME ASSIS SE SOUVIENT D'AVOIR ÉTÉ VOLÉ DANS LA VAGUE 1 : TE TUE
function day_entity_1:on_interaction()
    if game:get_value("labors_tott_minigame_hookshot_stolen") and not game:get_value("labors_1st_solarus_quest_minigame_man_had_fun") then
        game:start_dialog("LABORS.1st_solarus_quest.lake_village.seaten_man_kill",function()
            game:set_value("labors_1st_solarus_quest_minigame_man_had_fun", true)
            game:set_life(0)
            sol.timer.start(game, 3000, function()
                sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/gonna_cry")
            end)
        end)
    else game:start_dialog("LABORS.1st_solarus_quest.lake_village.seaten_man") end
end
local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")

    --Plus nécessaire de devoir revaincre les monstres si Saria a été sauvée
    if game:get_value("door_10019_4") then
        for enemy in map:get_entities("auto_enemy_auto_door_") do
            enemy:remove()
        end
    end
end)

-- PARLER A SARIA POUR LA SAUVER ET REPARTIR
function saria:on_interaction()
    game:start_dialog("LABORS.forest_village.saria_quest.save",function()
        hero:freeze()
        game:set_pause_allowed(false)
        game:set_life(game:get_max_life())
        game:set_magic(game:get_max_magic())
        sol.audio.play_music("victory")
        sol.timer.start(8000,function() 
           hero:start_victory()
           sol.timer.start(1000,function()
              game:set_pause_allowed(true)
            hero:teleport("creations/labors/1st_solarus_quest/forest_village/chief_house","front_chief","fade")
           end)     
        end)        
    end)
end
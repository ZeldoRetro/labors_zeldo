local map = ...
local game = map:get_game()

-- INTERACTION AVEC AGAHNIM: DIALOGUES PUIS LANCEMENT DU COMBAT
function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  hero:freeze()
  sol.timer.start(1000,function() 
    game:start_dialog("agahnim.3.intro",function()
      agahnim:get_sprite():set_direction(3)
      game:start_dialog("agahnim.3.intro_2",function()
        hero:unfreeze()
        map:set_entities_enabled("escalier",false)
        agahnim:set_enabled(false)
        boss:set_enabled(true)
        sol.audio.play_music("creations/labors/tott/agahnim_battle_2")
      end)
    end)
  end)
end
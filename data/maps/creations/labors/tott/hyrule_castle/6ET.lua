local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
if game:get_value("agahnim_assault") then
  local separator_manager = require("maps/lib/separator_manager")
  separator_manager:manage_map(map)
end

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end


--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Boss
  if game:get_value("boss_10007") then boss_sensor:set_enabled(false) else boss:set_enabled(false) end
end)

--INTERACTION AVEC AGAHNIM: DIALOGUES PUIS LANCEMENT DU COMBAT
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

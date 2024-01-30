local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  
  self:set_brandish_when_picked(false)
  self:set_savegame_variable("possession_flight_song")
  self:set_assignable(true)

end

-- Event called when the hero is using this item.
function item:on_using()

  local map = game:get_map()
  local hero = map:get_hero()
  local ocarina = game:get_item("inventory/ocarina")
  local dungeon = game:get_dungeon()
  hero:freeze()
  ocarina:playing_song("ocarina/flight_song", 3500,function()
    --OVERWORLD: TÉLÉPORTATION
    if map:get_world() == "outside_light" or map:get_world() == "outside_light_2" then
      hero:teleport("creations/forgotten_legend/telep_light_world","destination")
    --DONJON: RETOUR A L'ENTRÉE
    elseif dungeon ~= nil then
      game:start_dialog("_teleport_to_entrance",function(answer)
        if answer == 1 then
          sol.audio.play_sound("warp")
          hero:teleport(game:get_starting_location())
        end
      end)
    --RIEN
    else
      game:start_dialog("_cant_teleport")
    end
  end)
  item:set_finished() 
end
local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  
  self:set_brandish_when_picked(false)
  self:set_savegame_variable("possession_zelda_song")
  self:set_assignable(true)

end

-- Event called when the hero is using this item.
function item:on_using()

  local map = game:get_map()
  local hero = map:get_hero()
  local ocarina = game:get_item("inventory/ocarina")
  hero:freeze()
  ocarina:playing_song("ocarina/zelda_song", 9000, function()
    game:set_value("zelda_song_detected",true)
    sol.timer.start(game, 10, function() game:set_value("zelda_song_detected",false) end)
  end)
  item:set_finished() 
end
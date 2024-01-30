local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  
  self:set_brandish_when_picked(false)
  self:set_savegame_variable("possession_sun_song")
  self:set_assignable(true)

end

-- Event called when the hero is using this item.
function item:on_using()

  local map = game:get_map()
  local hero = map:get_hero()
  local ocarina = game:get_item("inventory/ocarina")
  hero:freeze()
  ocarina:playing_song("ocarina/sun_song", 4000)
  item:set_finished() 
end
--Spoils bag

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_treasures_bag")
  self:set_shadow("small")
  self:set_sound_when_picked(nil)
  self:set_assignable(true)
end

function item:on_using()
  self:set_finished()
end
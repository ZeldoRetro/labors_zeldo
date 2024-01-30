--Clock: Allows you to skip to the next day/night cycle

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_clock")
  self:set_sound_when_picked(nil)
  self:set_assignable(true)
end

function item:on_using()
  self:set_finished()
end
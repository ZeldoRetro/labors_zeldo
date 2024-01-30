--Fairy Power fragment: A fragment of the power of a Great Fairy.

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_fairy_power_fragment")
  self:set_amount_savegame_variable("fairy_power_fragment_amount")
  self:set_sound_when_picked(nil)
  self:set_max_amount(150)
  self:set_assignable(true)
end

function item:on_obtained()
  self:add_amount(1)
end

function item:on_using()
  self:set_finished()
end
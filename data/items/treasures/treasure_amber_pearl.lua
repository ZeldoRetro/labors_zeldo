--Amber pearl: Treasure example.

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_amber_pearl")
  self:set_amount_savegame_variable("amber_pearl_amount")
  self:set_shadow("small")
  self:set_sound_when_picked(nil)
  self:set_max_amount(99)
  self:set_assignable(true)
end

function item:on_obtained()
  self:add_amount(1)
end

function item:on_using()
  self:set_finished()
end
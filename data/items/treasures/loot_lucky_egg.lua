--Lucky egg: Rarest loot in a quest.

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_lucky_egg")
  self:set_amount_savegame_variable("lucky_egg_amount")
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
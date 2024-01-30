--Moon: Rarest treasure in a quest. Easter egg of Mario Odyssey.

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_moon")
  self:set_amount_savegame_variable("moon_amount")
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("treasure_moon")
  self:set_max_amount(99)
  self:set_assignable(true)
end

function item:on_obtained()
  self:add_amount(1)
end

function item:on_using()
  self:set_finished()
end
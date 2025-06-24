-- Fidelity Card: Buy items in the Great Shop ang gain fidelity points !

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_fidelity_card_1st_solarus_quest")
  self:set_amount_savegame_variable("fidelity_card_1st_solarus_quest_points_amount")
  self:set_sound_when_picked(nil)
  self:set_max_amount(99)
  self:set_assignable(true)
end

function item:on_using()
  self:set_finished()
end
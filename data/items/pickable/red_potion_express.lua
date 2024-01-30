local item = ...
local map = item:get_map()

function item:on_created()

  self:set_shadow("big")
  self:set_sound_when_brandished("correct")
  self:set_sound_when_picked(nil)
end

function item:on_obtaining(variant, savegame_variable)
  self:get_game():add_life(16*4)
end
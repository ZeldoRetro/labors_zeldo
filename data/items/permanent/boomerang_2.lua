-- Permanent Item : Kept during the current Wave

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_perma_boomerang_2")
end
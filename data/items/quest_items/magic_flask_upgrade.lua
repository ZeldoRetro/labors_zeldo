--Magic flask upgrade: Grows up your magic bar.

local item = ...

function item:on_created()
  self:set_shadow("small")
  self:set_sound_when_picked(nil)
  self:set_savegame_variable("possession_magic_flask_upgrade")
end

function item:on_obtained()
  self:get_game():set_max_magic(84)
end
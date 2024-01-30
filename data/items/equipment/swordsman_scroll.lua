--Swordsman scroll: Allows you to do the tornado spin attack.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_swordsman_scroll")
end

function item:on_obtaining()
  self:get_game():set_ability("sword_knowledge", 1)
end
--Sword: increases the attack.

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword_PLAYER")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_obtained(variant)
  local game = item:get_game()
  local hero = game:get_hero()
  self:get_game():set_ability("sword", 6)
  hero:start_victory()
end
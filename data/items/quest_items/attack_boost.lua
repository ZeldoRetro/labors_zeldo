--Boost: increases the attack.

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_attack_boost")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end


function item:on_obtaining(variant)

  -- Obtaining the sword increases the force.
  local game = item:get_game()
  local map = game:get_map()
  local force = game:get_value("force")
  force = force + 1
  game:set_value("force", force)
end
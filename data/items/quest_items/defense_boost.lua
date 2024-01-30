--Boost: increases the defense.

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_defense_boost")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end


function item:on_obtaining(variant)

  -- Obtaining the sword increases the defense.
  local game = item:get_game()
  local map = game:get_map()
  local defense = game:get_value("defense")
  defense = defense + 1
  game:set_value("defense", defense)
end
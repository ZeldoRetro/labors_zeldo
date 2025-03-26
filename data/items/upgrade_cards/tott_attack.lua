--Upgrade Card

local item = ...
local game = item:get_game()
local map = game:get_map()

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_tott_upgrade_card_attack")
end

function item:on_using()
  local variant = item:get_variant()
  local force = game:get_value("force")

  if variant == 1 then
    game:set_value("tott_upgrade_card_force_active",true)
    game:set_value("force", force + 1)
  else
    game:set_value("tott_upgrade_card_force_active",false)
    game:set_value("force", force - 1)
  end
end

function item:on_variant_changed()
  item:on_using()
end
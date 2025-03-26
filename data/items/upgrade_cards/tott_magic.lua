--Upgrade Card

local item = ...
local game = item:get_game()
local map = game:get_map()

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_tott_upgrade_card_magic")
end

function item:on_using()
  local variant = item:get_variant()
  local current_magic = game:get_magic()

  if variant == 1 then
    game:set_value("tott_upgrade_card_magic_active",true)
    game:get_item("magic_bar"):set_variant(2)
  else
    game:set_value("tott_upgrade_card_magic_active",false)
    game:get_item("magic_bar"):set_variant(1)
  end
  game:set_magic(current_magic)
end

function item:on_variant_changed()
  item:on_using()
end

function item:on_obtaining()
  game:get_item("magic_bar"):set_variant(2)
end
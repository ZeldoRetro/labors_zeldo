--Upgrade Card

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_tott_upgrade_card_casual")
end

function item:on_using()
  local variant = item:get_variant()

  if variant == 1 then
    game:set_value("tott_upgrade_card_casual_active",true)
    if game:get_map() ~= nil then game:get_map():set_entities_enabled("casual_entity",true) end
  else
    game:set_value("tott_upgrade_card_casual_active",false)
    if game:get_map() ~= nil then game:get_map():set_entities_enabled("casual_entity",false) end
  end
end

function item:on_variant_changed()
  item:on_using()
end
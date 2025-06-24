-- Shield 1st Solarus Quest

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_shield_1st_solarus_quest")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the shield determines the built-in ability "shield".
  self:get_game():set_ability("shield", variant)
end

function item:on_obtained()
  -- Increase the defense level of 1
  local game = item:get_game()
  local defense = game:get_value("defense")
  defense = defense + 1
  game:set_value("defense", defense)
  game:get_map():get_hero():set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield"..item:get_variant())
end
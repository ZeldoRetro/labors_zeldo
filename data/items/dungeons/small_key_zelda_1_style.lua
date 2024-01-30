--Small key: a standard small key who opens a locked door. The Zelda 1 style permits the player to use them in any dungeon.

local item = ...

function item:on_created()
  self:set_savegame_variable("possession_small_keys_zelda_1")
  self:set_amount_savegame_variable("small_keys_zelda_1_amount")
  self:set_shadow("small")
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("treasure_key")
  self:set_max_amount(99)
end

function item:on_obtained()
  self:add_amount(1)
end
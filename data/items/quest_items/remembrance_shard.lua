--Remembrance Shard

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_remembrance_shard")
  self:set_amount_savegame_variable("remembrance_shard_amount")
  self:set_max_amount(999)
  self:set_sound_when_picked(nil)
  self:set_shadow("small")
end

function item:on_obtained(variant, savegame_variable)

  local amounts = {1, 5, 10, 25}
  local amount = amounts[variant]

  game:get_item("quest_items/remembrance_shard"):add_amount(amount)

  game:set_value("remembrance_shard_found",game:get_value("remembrance_shard_found") + amount)
end
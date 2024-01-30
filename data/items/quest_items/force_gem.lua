--Force Gem: A mysterious gem...

local item = ...
local game = item:get_game()

function item:on_created()
    self:set_amount_savegame_variable("force_gem_amount")
    self:set_sound_when_picked(nil)
    self:set_max_amount(200)
end

function item:on_obtained(variant, savegame_variable)

  local amounts = {1, 5, 10, 20}
  local amount = amounts[variant]

  game:get_item("quest_items/force_gem"):add_amount(amount)
  if game:get_value("force_gem_amount") == item:get_max_amount() then
    game:set_value("all_force_gems",true)
  end
end
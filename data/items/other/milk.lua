--Milk

local item = ...
local map = item:get_map()
local game = item:get_game()

function item:on_obtaining(variant, savegame_variable)

  local first_empty_bottle = self:get_game():get_first_empty_bottle()

  if first_empty_bottle ~= nil then
    first_empty_bottle:set_variant(7)
  end
end
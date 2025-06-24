local map = ...
local game = map:get_game()

-- DÉBUT DE LA MAP
map:register_event("on_started",function()

  -- Porte ouverte et yeux activés
  if game:get_value("door_10013_1") then
    block_puzzle_1_switch_1_torch:set_lit(true)
    block_puzzle_1_switch_2_torch:set_lit(true)
    block_puzzle_1_switch_3_torch:set_lit(true)
  end
end)
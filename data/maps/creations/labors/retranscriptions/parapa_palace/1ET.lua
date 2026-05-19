local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Clé 3 obtenue
  if game:get_value("key_10022_3") then 
    auto_chest_key_2:set_enabled(true) 
    auto_switch_auto_chest_key_2:set_enabled(true)
    block_puzzle_1_fake_switch:set_enabled(false)
    local x1, y1 = block_puzzle_1_switch_1:get_position()
    local x2, y2 = block_puzzle_1_switch_2:get_position()
    block_puzzle_1_block_1:set_position(x1 + 8, y1 + 13)
    block_puzzle_1_block_1:set_pushable(false)
    block_puzzle_1_block_1:set_pullable(false)
    block_puzzle_1_block_2:set_position(x2 + 8, y2 + 13)
    block_puzzle_1_block_2:set_pushable(false)
    block_puzzle_1_block_2:set_pullable(false)
  else auto_switch_auto_chest_key_2:set_enabled(false) end

end)

--ENIGME DE BLOCS POUR CLE 3
function block_puzzle_1_fake_switch:on_activated()
    sol.timer.start(500,function() 
      block_puzzle_1_block_1:reset()
      block_puzzle_1_block_2:reset()
      sol.audio.play_sound("wrong") 
      block_puzzle_1_fake_switch:set_activated(false) 
    end)
end

local block_puzzle_1_switches = 0
local goal_block_puzzle_1 = 2
for switch in map:get_entities("block_puzzle_1_switch") do
  function switch:on_activated()
    block_puzzle_1_switches = block_puzzle_1_switches + 1
    if block_puzzle_1_switches == goal_block_puzzle_1 then
      auto_switch_auto_chest_key_2:set_enabled(true)
      block_puzzle_1_fake_switch:set_enabled(false)
    end
  end
  function switch:on_inactivated()
    block_puzzle_1_switches = block_puzzle_1_switches - 1
  end
end
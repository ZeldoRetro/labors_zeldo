local map = ...
local game = map:get_game()

-- ÉNIGME BLOCS ET TROUS: LES BLOCS TOMBÉS DANS UN TROU RESPAWNENT
block_puzzle_2_fake_switch:register_event("on_activated", function(switch)
  sol.timer.start(map, 490, function()
    if not map:has_entity("block_puzzle_2_block_1") then
      local block = map:create_block({
        name = "block_puzzle_2_block_1",
        layer = 1,
        x = 792,
        y = 1517,
        properties = {
          {
            key = "disable_if_value",
            value = "door_10014_12",
          },
        },
        sprite = "entities/blocks/white_block",
        pushable = true,
        pullable = false,
        maximum_moves = 2,
      })
      block:bring_to_back()
    end
    if not map:has_entity("block_puzzle_2_block_2") then
      local block = map:create_block({
        name = "block_puzzle_2_block_2",
        layer = 1,
        x = 808,
        y = 1517,
        properties = {
          {
            key = "disable_if_value",
            value = "door_10014_12",
          },
        },
        sprite = "entities/blocks/white_block",
        pushable = true,
        pullable = false,
        maximum_moves = 2,
      })
      block:bring_to_back()
    end
  end)
end)
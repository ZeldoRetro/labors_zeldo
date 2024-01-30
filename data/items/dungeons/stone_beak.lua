--Stone beak: allows you to read the clues on owl statues.

local item = ...

function item:on_obtaining(variant, savegame_variable)

  -- Save the possession of the stone beak in the current dungeon.
  local game = self:get_game()
  local dungeon = game:get_dungeon_index()
  if dungeon == nil then
    error("This item is not in a dungeon")
  end
  game:set_value("dungeon_" .. dungeon .. "_stone_beak", true)
end
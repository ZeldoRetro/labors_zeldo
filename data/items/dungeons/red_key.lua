--Big Key: opens the big key doors and big chest of a dungeon.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
end

function item:on_obtaining(variant, savegame_variable)
	  -- Save the possession of the boss key in the current dungeon.
  local game = self:get_game()
  local dungeon = game:get_dungeon_index()
  if dungeon == nil then
    error("This map is not in a dungeon")
  end
  game:set_value("dungeon_" .. dungeon .. "_red_key", true)
end
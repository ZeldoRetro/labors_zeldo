-- Defines the dungeon information of a game.

-- Usage:
-- local dungeon_manager = require("scripts/dungeons")
-- dungeon_manager:create(game)

local dungeon_manager = {}

function dungeon_manager:create(game)

  -- Define the existing dungeons and their floors for the minimap menu.
  local dungeons_info = {
    [0] = {
      lowest_floor = -1,
      highest_floor = 0,
      maps = { "examples/dungeon_example/RDC", "examples/dungeon_example/SS1" },
      key_item = {
        floor = 0,
        x = 880 + 3520 + 40 + 160,
        y = 678 - 32 - 240,
        savegame_variable = "get_farore_pearl",
      }
    },

    [1001] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/another_hyrule_fantasy/dungeons/1" },
      key_item = {
        floor = 0,
        x = 1840 + 3520 - 440,
        y = 1400 - 32 - 1000,
        savegame_variable = "get_triforce_1",
      }
    },

    [10001] = {
      lowest_floor = -3,
      highest_floor = 0,
      maps = { "creations/labors/tott/water_temple/RDC","creations/labors/tott/water_temple/SS1","creations/labors/tott/water_temple/SS2","creations/labors/tott/water_temple/SS3" },
      key_item = {
        floor = 0,
        x = 1840 + 3520 - 440,
        y = 1400 - 32 - 1000,
        savegame_variable = "get_trophy_10001",
      }
    },
    [10002] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/labors/tott/ancient_catacombs/SS1" },
      key_item = {
        floor = 0,
        x = 1840 + 3720,
        y = 1400 - 32 - 480,
        savegame_variable = "get_trophy_10002",
      }
    },
    [10004] = {
      lowest_floor = 0,
      highest_floor = 3,
      maps = { "creations/labors/tott/fire_temple/RDC","creations/labors/tott/fire_temple/1ET","creations/labors/tott/fire_temple/2ET","creations/labors/tott/fire_temple/3ET" },
      key_item = {
        floor = 3,
        x = 1840 + 4200 - 480,
        y = 1400 - 32 - 480,
        savegame_variable = "get_trophy_10004",
      }
    },
  }

  -- Returns the index of the current dungeon if any, or nil.
  function game:get_dungeon_index()

    local world = game:get_map():get_world()
    if world == nil then
      return nil
    end
    local index = tonumber(world:match("^dungeon_([0-9]+)$"))
    return index
  end

  -- Returns the current dungeon if any, or nil.
  function game:get_dungeon()

    local index = game:get_dungeon_index()
    return dungeons_info[index]
  end

  function game:is_dungeon_finished(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_finished")
  end

  function game:set_dungeon_finished(dungeon_index, finished)
    if finished == nil then
      finished = true
    end
    dungeon_index = dungeon_index or game:get_dungeon_index()
    game:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
  end

  function game:get_num_main_quest_items()

    local num_finished = 0
    for i = 0, 8 do
      if game:is_dungeon_finished(i) then
        num_finished = num_finished + 1
      end
    end
    return num_finished
  end

  function game:has_dungeon_map(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_map")
  end
  function game:has_dungeon_compass(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_compass")
  end
  function game:has_dungeon_boss_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_boss_key")
  end
  function game:has_dungeon_big_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_big_key")
  end
  function game:has_dungeon_stone_beak(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_stone_beak")
  end


  function game:get_dungeon_name(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return sol.language.get_string("dungeon_" .. dungeon_index .. ".name")
  end

  -- Returns the name of the boolean variable that stores the exploration
  -- of a dungeon room, or nil.
  function game:get_explored_dungeon_room_variable(dungeon_index, floor, room)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    room = room or 1

    if floor == nil then
      if game:get_map() ~= nil then
        floor = game:get_map():get_floor()
      else
        floor = 0
      end
    end

    local room_name
    if floor >= 0 then
      room_name = tostring(floor + 1) .. "f_" .. room
    else
      room_name = math.abs(floor) .. "b_" .. room
    end

    return "dungeon_" .. dungeon_index .. "_explored_" .. room_name
  end

  -- Returns whether a dungeon room has been explored.
  function game:has_explored_dungeon_room(dungeon_index, floor, room)

    return self:get_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room)
    )
  end

  -- Changes the exploration state of a dungeon room.
  function game:set_explored_dungeon_room(dungeon_index, floor, room, explored)

    if explored == nil then
      explored = true
    end

    self:set_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room),
      explored
    )
  end

end

return dungeon_manager
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

    [4] = {
      lowest_floor = -1,
      highest_floor = 2,
      maps = { "creations/forgotten_legend/dungeons/4/SS1", "creations/forgotten_legend/dungeons/4/RDC", "creations/forgotten_legend/dungeons/4/1ET", "creations/forgotten_legend/dungeons/4/1ET_outside", "creations/forgotten_legend/dungeons/4/2ET" },
      key_item = {
        floor = 2,
        x = 1840 + 3520 - 160,
        y = 1400 - 32 - 720,
        savegame_variable = "get_din_pearl_2",
      }
    },

    [1001] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/another_hyrule_fantasy/dungeons/1" },
      key_item = {
        floor = 0,
        x = 1840 + 4160 - 440,
        y = 1400 - 520,
        savegame_variable = "get_triforce_1",
      }
    },

    [10001] = {
      lowest_floor = -3,
      highest_floor = 0,
      maps = { "creations/labors/tott/water_temple/RDC","creations/labors/tott/water_temple/SS1","creations/labors/tott/water_temple/SS2","creations/labors/tott/water_temple/SS3" },
      key_item = {
        floor = -3,
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
    [10011] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/labors/1st_solarus_quest/link_forest/courage_palace" },
      key_item = {
        floor = 0,
        x = 1440 + 4200 - 780 + 64,
        y = 100 + 240 + 32,
        savegame_variable = "get_trophy_10011",
      }
    },
    [10014] = {
      lowest_floor = 0,
      highest_floor = 7,
      maps = { "creations/labors/1st_solarus_quest/power_temple/1ET","creations/labors/1st_solarus_quest/power_temple/2ET","creations/labors/1st_solarus_quest/power_temple/3ET","creations/labors/1st_solarus_quest/power_temple/4ET","creations/labors/1st_solarus_quest/power_temple/5ET","creations/labors/1st_solarus_quest/power_temple/6ET","creations/labors/1st_solarus_quest/power_temple/7ET","creations/labors/1st_solarus_quest/power_temple/RDC" },
      key_item = {
        floor = 7,
        x = 1440 + 4200 - 780 + 64,
        y = 100 + 1200 + 32,
        savegame_variable = "get_trophy_10014",
      }
    },
    [10015] = {
      lowest_floor = -2,
      highest_floor = 0,
      maps = { "creations/labors/1st_solarus_quest/wisdom_temple/RDC","creations/labors/1st_solarus_quest/wisdom_temple/SS1","creations/labors/1st_solarus_quest/wisdom_temple/SS2" },
      key_item = {
        floor = 0,
        x = 1440 + 4200 - 780 + 64,
        y = 100 + 480 + 32,
        savegame_variable = "get_trophy_10015",
      }
    },
    [10017] = {
      lowest_floor = -2,
      highest_floor = 1,
      maps = { "creations/labors/1st_solarus_quest/hyrule_castle/1ET","creations/labors/1st_solarus_quest/hyrule_castle/RDC","creations/labors/1st_solarus_quest/hyrule_castle/SS1","creations/labors/1st_solarus_quest/hyrule_castle/SS2" },
      key_item = {
        floor = -2,
        x = 1440 + 4200 - 780 + 64,
        y = 100 + 240 + 480 + 32,
        savegame_variable = "get_trophy_10017",
      }
    },
    [10021] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/labors/retranscriptions/eagle_ruins/RDC","creations/labors/retranscriptions/eagle_ruins/SS1" },
      key_item = {
        floor = 0,
        x = 1840 + 4160 - 440,
        y = 1400 - 520,
        savegame_variable = "get_trophy_10021",
      }
    },
    [10022] = {
      lowest_floor = -1,
      highest_floor = 1,
      maps = { "creations/labors/retranscriptions/parapa_palace/1ET", "creations/labors/retranscriptions/parapa_palace/RDC", "creations/labors/retranscriptions/parapa_palace/SS1" },
      key_item = {
        floor = -1,
        x = 1840 + 3520 - 440,
        y = 1400 - 500,
        savegame_variable = "get_trophy_10022",
      }
    },
    [10023] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "creations/labors/retranscriptions/moon_ruins/RDC" },
      key_item = {
        floor = 0,
        x = 1840 + 3200 - 440,
        y = 1400 - 1000,
        savegame_variable = "get_trophy_10023",
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
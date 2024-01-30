local map = ...
local game = map:get_game()

texte_lieu = sol.text_surface.create{
  text_key = "location.tott.ice_cavern",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)

local ice_knights_targets = {}
local ice_knights = {}

--DEBUT DE LA MAP
function map:on_started(destination)

  --Equipement requis + Initialisation variables
  if destination == start then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")

    game:set_max_life(6*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(1)
    game:get_item("equipment/shield"):set_variant(1)

    game:set_value("force",1)
    game:set_value("defense",1)

    game:get_item("magic_bar"):set_variant(1)
    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("equipment/glove"):set_variant(1)
    game:set_ability("lift",1)

  end

  --Enigme faite
  if game:get_value("trophy_10003") then
    map:set_doors_open("auto_door_1")
    auto_switch_auto_door_1:set_activated(true)
    auto_switch_auto_door_1:set_locked()
    map:set_doors_open("auto_door_2")
    auto_switch_auto_door_2:set_activated(true)
    auto_switch_auto_door_2:set_locked()
    map:set_doors_open("auto_door_3")
    auto_switch_auto_door_3:set_activated(true)
    auto_switch_auto_door_3:set_locked()
  end

  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then map:set_entities_enabled("day_entity",true) else map:set_entities_enabled("day_entity",false) end

end

--ENIGMES DES BLOCS SUR GLACE

local function check_ice_knight(block)

  block.correct = false
  for _, target in ipairs(ice_knights_targets) do
    if target:overlaps(block, "containing") then
      block.correct = true
      return
    end
  end
end

local function block_on_moved_ice(block)

  hero:unfreeze()

  local x, y, layer = block:get_position()

  -- Create a wall to prevent the hero from overlapping the block
  -- when it moves alone.
  local wall = map:create_wall({
    x = x - 8,
    y = y - 13,
    layer = layer,
    width = 16,
    height = 16,
    stops_hero = true,
    stops_blocks = false,
  })

  -- Move the block towards the next obstacle.
  local direction4 = hero:get_direction()
  local movement = sol.movement.create("straight")
  movement:set_speed(64)
  movement:set_angle(direction4 * math.pi / 2)
  movement:start(block)

  -- Stop the movement when reaching an obstacle.
  function movement:on_obstacle_reached()
    block:stop_movement()
    wall:remove()
    check_ice_knight(block)
  end

  -- Keep the wall in the block.
  function movement:on_position_changed()

    local x, y = block:get_position()
    wall:set_position(x - 8, y - 13)
  end
end

for knight in map:get_entities("auto_block_knight") do
  ice_knights[#ice_knights + 1] = knight
  knight.on_moved = block_on_moved_ice
end
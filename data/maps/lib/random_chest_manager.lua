-- Random specific chests in the map (for randomizer ?)

local random_chest_manager = {}

function random_chest_manager:create_random_chest(map, prefix, rewards)

  local game = map:get_game()
  local good_chest_index

  local function on_opened(chest)

    local hero = game:get_hero()
    local item_name, variant, savegame_variable = unpack(rewards[math.random(#rewards)])
    while savegame_variable ~= nil and game:get_value(savegame_variable) do
      item_name, variant, savegame_variable = unpack(rewards[math.random(#rewards)])
    end
    hero:start_treasure(item_name, variant, savegame_variable)
  end

  for chest in map:get_entities(prefix .. "_chest_") do
    if chest:get_type() == "chest" then
      chest.on_opened = on_opened
    end
  end

end

return random_chest_manager
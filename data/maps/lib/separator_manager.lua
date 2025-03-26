-- This script restores entities when there are separators in a map.
-- When taking separators prefixed by "auto_separator", the following entities are restored:
-- - Destructibles prefixed by "auto_destructible".
-- - Blocks prefixed by "auto_block".
-- And the following entities are destroyed:
-- - Bombs.

local separator_manager = {}
require("scripts/multi_events")

function separator_manager:manage_map(map)

  local enemy_starting_positions = {}
  local destructible_places = {}
  local custom_entity_places = {}
  local game = map:get_game()

  -- Function called when a separator was just taken.
  local function separator_on_activated(separator)

    map:set_entities_enabled("ice_path",false)
    local hero = map:get_hero()

    -- Blocks.
    for block in map:get_entities("auto_block") do
      -- Reset blocks in regions no longer visible.
      if not block:is_in_same_region(hero) then
        block:reset()
      end
    end

  end

  -- Function called when a separator is being taken.
  local function separator_on_activating(separator, direction4)

    local hero = map:get_hero()

    -- Destructibles.
    for _, destructible_place in ipairs(destructible_places) do
      local destructible = destructible_place.destructible

      if not destructible:exists() then
        -- Re-create destructibles in all regions except the active one.
        if not destructible:is_in_same_region(hero) then
          local destructible = map:create_destructible({
            x = destructible_place.x,
            y = destructible_place.y,
            layer = destructible_place.layer,
            name = destructible_place.name,
            sprite = destructible_place.sprite,
            destruction_sound = destructible_place.destruction_sound,
            weight = destructible_place.weight,
            can_be_cut = destructible_place.can_be_cut,
            can_explode = destructible_place.can_explode,
            can_regenerate = destructible_place.can_regenerate,
            damage_on_enemies = destructible_place.damage_on_enemies,
            ground = destructible_place.ground,
          })
          -- We don't recreate the treasure.
          destructible_place.destructible = destructible
          destructible:bring_to_back() -- Workaround : Ensure the created destructible is under a possible invisible entity such as lights, to let it liftable again after thrown.
        end
      end
    end

    -- Custom entities.
    for _, custom_entity_place in ipairs(custom_entity_places) do
      local custom_entity = custom_entity_place.custom_entity

      if not custom_entity:exists() then
        -- Re-create custom_entity in all regions except the active one.
        if not custom_entity:is_in_same_region(hero) then
          local custom_entity = map:create_custom_entity({
            direction = custom_entity_place.direction,
            x = custom_entity_place.x,
            y = custom_entity_place.y,
            layer = custom_entity_place.layer,
            width = custom_entity_place.width,
            height = custom_entity_place.height,
            name = custom_entity_place.name,
            sprite = custom_entity_place.sprite,
            model = custom_entity_place.model,
          })
          -- We don't recreate the treasure.
          custom_entity_place.custom_entity = custom_entity
          custom_entity:bring_to_back()

        end
      end
    end

    -- Enemies
    -- disable enemies in the current room
    for entity in map:get_entities_in_region(map:get_camera()) do
      local is_boss = entity:get_property("is_major") == "true"
      if entity:get_type() == "enemy" and not is_boss then
        entity:set_enabled(false)
        -- reset enemy position to its starting location
        local address = string.format("%p", entity)
        local pos = enemy_starting_positions[address]
        if pos ~= nil then
          entity:set_position(pos[1], pos[2])
        end
      end
    end

    -- clear enemy positions from previous room
    local count = #enemy_starting_positions
    for j = 1, count do enemy_starting_positions[j] = nil end

    -- compute next room position
    local target_x, target_y = hero:get_position()
    if direction4 == 0 then
      target_x = target_x + 16
    elseif direction4 == 1 then
      target_y = target_y - 16
    elseif direction4 == 2 then
      target_x = target_x - 16
    elseif direction4 == 3 then
      target_y = target_y + 16
    end

    -- enable enemies in the next room
    for entity in map:get_entities_in_region(target_x, target_y) do
      local is_boss = entity:get_property("is_major") == "true"
      if entity:get_type() == "enemy" and not is_boss then
        entity:set_enabled(true)
        local address = string.format("%p", entity)

        -- save enemy starting location when leaving the room
        local pos_x, pos_y = entity:get_position()
        enemy_starting_positions[address] = { pos_x, pos_y }
      end
    end

  end

  for separator in map:get_entities("auto_separator") do
    separator.on_activating = separator_on_activating
    separator.on_activated = separator_on_activated
  end


  local function get_destructible_sprite_name(destructible)
    -- TODO the engine should have a destructible:get_sprite() method.
    -- As a temporary workaround we use the one of custom entity, fortunately
    -- it happens to work for all types of entities.
    local sprite = sol.main.get_metatable("custom_entity").get_sprite(destructible)
    return sprite ~= nil and sprite:get_animation_set() or ""
  end

  -- Store the position and properties of destructibles.
  for destructible in map:get_entities("auto_destructible") do
    local x, y, layer = destructible:get_position()
    destructible_places[#destructible_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      name = destructible:get_name(),
      treasure = { destructible:get_treasure() },
      sprite = get_destructible_sprite_name(destructible),
      destruction_sound = destructible:get_destruction_sound(),
      weight = destructible:get_weight(),
      can_be_cut = destructible:get_can_be_cut(),
      can_explode = destructible:get_can_explode(),
      can_regenerate = destructible:get_can_regenerate(),
      damage_on_enemies = destructible:get_damage_on_enemies(),
      ground = destructible:get_modified_ground(),
      destructible = destructible,
    }
  end

  -- Store the position and properties of destructibles.
  for custom_entity in map:get_entities("auto_custom_entity") do
    local x, y, layer = custom_entity:get_position()
    local width, height = custom_entity:get_size()
    custom_entity_places[#custom_entity_places + 1] = {
      direction = custom_entity:get_direction(),
      x = x,
      y = y,
      layer = layer,
      width = width,
      height = height,
      name = custom_entity:get_name(),
      sprite = custom_entity:get_sprite():get_animation_set(),
      model = custom_entity:get_model(),
      custom_entity = custom_entity,
    }
  end

end

return separator_manager
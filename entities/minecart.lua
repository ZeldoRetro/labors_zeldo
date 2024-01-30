-- A minecart to be used by the hero on railroads.

local minecart = ...
local map = minecart:get_map()
local game = minecart:get_game()
local hero = map:get_hero()
local name = minecart:get_name()

-- Whether the hero is facing the minecart stopped.
local hero_facing_minecart = false
local action_command_minecart = false

-- Don't let the hero traverse the minecart.
minecart:set_traversable_by("hero", false)

-- Hurt enemies hit by the minecart.
minecart:add_collision_test("sprite", function(minecart, other)

  if other:get_type() == "enemy" then
    other:hurt(8)
  end
end)

-- Detect minecart turns.
minecart:add_collision_test("containing", function(minecart, other)

  if other:get_type() == "custom_entity" then

    if other:get_model() == "minecart_turn" then
      local movement = hero:get_movement()
      if movement ~= nil then
        -- Simply change the hero's movement direction.
        local direction4 = other:get_direction()
        movement:set_angle(direction4 * math.pi / 2)
        minecart:get_sprite():set_direction(direction4)
        hero:set_direction(direction4)
      end
    end

    if other:get_model() == "minecart_turn_diagonal" then
      local movement = hero:get_movement()
      if movement ~= nil then
        -- Simply change the hero's movement direction.
        local direction8 = other:get_direction() * 2 + 1
        movement:set_angle(direction8 * math.pi / 4)
        local direction4 = (direction8 == 1 or direction == 7) and 0 or 2
        hero:set_direction(direction4)
      end
    end

  end
end)

-- Detect minecart stops.
minecart:add_collision_test("overlapping", function(minecart, other)

  if other:get_type() == "custom_entity" then

    if other:get_model() == "minecart_stop" then
      minecart:stop()
    end

  end

end)

-- Show an action icon when the player faces the minecart.
minecart:add_collision_test("facing", function(minecart, other)

  if other:get_type() == "hero" then

    hero_facing_minecart = true
    if minecart:get_movement() == nil
      and game:get_command_effect("action") == nil
      and game:get_custom_command_effect("action") == nil then
      action_command_minecart = true
      game:set_custom_command_effect("action", "action")
    end
  end

end)

-- Remove the action icon when stopping facing the minecart.
function minecart:on_update()

  if action_command_minecart and not hero_facing_minecart then
    game:set_custom_command_effect("action", nil)
    action_command_minecart = false
  end

  hero_facing_minecart = false
end

-- Called when the hero presses the action command near the minecart.
function minecart:on_interaction()

  local direction8
  local hero_direction = hero:get_direction()
  if hero_direction == 0 then direction8 = 0
  elseif hero_direction == 1 then direction8 = 2
  elseif hero_direction == 2 then direction8 = 4
  elseif hero_direction == 3 then direction8 = 6
  end

  if minecart:get_sprite():get_animation() == "stopped" then
    hero:set_invincible(true)
    hero:start_jumping(direction8,16,true)
    sol.timer.start(map, 200, function()
      minecart:go()
    end)
  end
end

-- Starts driving the minecart.
function minecart:go()

  hero:freeze()
  hero:set_position(minecart:get_position())
  hero:set_animation("minecart_driving")
  minecart:get_sprite():set_animation("driving")

  map:set_entities_enabled(name.."_stop",true)

  game:set_custom_command_effect("action", nil)
  action_command_minecart = false
  hero_facing_minecart = false

  -- Create a movement on the hero.
  local direction4 = minecart:get_direction()
  local movement = sol.movement.create("straight")
  movement:set_angle(direction4 * math.pi / 2)
  movement:set_speed(128)
  movement:set_smooth(false)
  movement:set_ignore_obstacles(true)

  function movement:on_position_changed()
    -- Put the minecart at the same position as the hero.
    minecart:set_position(hero:get_position())
  end

  -- Destroy the minecart when reaching an obstacle.
  function movement:on_obstacle_reached()
    --minecart:stop()
  end

  -- The hero must be allowed to traverse the minecart during the movement.
  minecart:set_traversable_by("hero", true)

  -- Allow the player to control the direction of the hero.
  if map.on_command_pressed == nil then
    -- TODO use map:register_event()
    function map:on_command_pressed(command)

      local directions4 = {
        right = 0,
        up = 1,
        left = 2,
        down = 3
      }
      local direction4 = directions4[command]
      if direction4 ~= nil then
        hero:set_direction(direction4)
        return true  -- Consume the event.
      end

      if command == "attack" then
        print("ok")
      end
      return false
    end
  end

  movement:start(hero)
end

-- Stops driving the minecart.
function minecart:stop()

  local minecart_sprite = minecart:get_sprite()
  minecart_sprite:set_animation("stopped")

  map:set_entities_enabled(name.."_stop",false)

  local direction8
  local minecart_direction_2
  local minecart_direction = minecart:get_sprite():get_direction()
  if minecart_direction == 0 then direction8 = 0 minecart_direction_2 = 2
  elseif minecart_direction == 1 then direction8 = 2 minecart_direction_2 = 3
  elseif minecart_direction == 2 then direction8 = 4 minecart_direction_2 = 0
  elseif minecart_direction == 3 then direction8 = 6 minecart_direction_2 = 1
  end


   -- Restore control to the player.
  map.on_command_pressed = nil
  hero:unfreeze()
  minecart:set_traversable_by("hero", false)
  minecart:set_direction(minecart_direction_2)
  hero:start_jumping(direction8,16,true)
  hero:set_invincible(false)
end


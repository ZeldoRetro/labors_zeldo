----------------------------------
--
-- Moldorm.
--
-- Caterpillar enemy with three body parts and one tail that will follow the head move.
-- Moves in curved motion, and randomly change the direction of the curve.
-- Speed up the move if set_angry() or hurt.
--
-- Methods : enemy:start_walking()
--           enemy:set_angry()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprites = {}
local head_sprite, tail_sprite
local tied_sprites_frame_lags = {}
local last_positions, frame_count
local walking_movement
local is_angry

-- Configuration variables
local walking_speed = 80
local walking_angle = 0.035
local running_speed = 144
local tied_sprites_frame_lags = {20, 35, 50, 62}
local keeping_angle_duration = 1500
local angry_duration = 3000
local before_explosion_delay = 2000
local between_explosion_delay = 500

-- Constants
local highest_frame_lag = tied_sprites_frame_lags[#tied_sprites_frame_lags] + 1
local sixteenth = math.pi * 0.125
local eighth = math.pi * 0.25
local quarter = math.pi * 0.5
local circle = math.pi * 2.0

local hit = false
local interval = 220

-- Update head sprite direction, and tied sprites offset.
local function update_sprites()

  -- Save current position
  local x, y, _ = enemy:get_position()
  last_positions[frame_count] = {x = x, y = y}

  -- Set the head sprite direction.
  local direction8 = math.floor((enemy:get_movement():get_angle() + sixteenth) % circle / eighth)
  if head_sprite:get_direction() ~= direction8 then
    head_sprite:set_direction(direction8)
  end

  -- Replace part sprites on a previous position.
  local function replace_part_sprite(sprite, frame_lag)
    local previous_position = last_positions[(frame_count - frame_lag) % highest_frame_lag] or last_positions[0]
    sprite:set_xy(previous_position.x - x, previous_position.y - y)
  end
  for i = 1, 4 do
    replace_part_sprite(sprites[i + 1], tied_sprites_frame_lags[i])
  end

  frame_count = (frame_count + 1) % highest_frame_lag
end

-- Hurt or repulse the hero depending on touched sprite.
local function on_attack_received()

  -- Don't hurt and only repulse if the hero sword sprite doesn't collide with the tail sprite.
  if enemy:overlaps(hero, "sprite", head_sprite, hero:get_sprite("sword")) then
    if not hit then
      hit = true
      sol.audio.play_sound("sword_tapping")
      enemy:start_pushing_back(hero, 200, 200, sprite, nil, function()
        enemy:set_invincible()
        enemy:set_hammer_reaction(on_attack_received)
        enemy:set_attack_consequence("sword", on_attack_received)

        enemy:set_arrow_reaction("protected")
        enemy:set_fire_reaction("protected")
        enemy:set_ice_reaction("protected")
        enemy:set_attack_consequence("explosion", "protected")
        enemy:set_attack_consequence("boomerang", "protected")
        enemy:set_hookshot_reaction("protected")
        hit = false
      end)
  elseif not enemy:overlaps(hero, "sprite", tail_sprite, hero:get_sprite("sword")) then
      return
    end
    return
  end

  -- Else hurt normally.
  enemy:hurt(1)
  walking_speed = walking_speed + 16
  interval = interval - 30
end

-- Start the enemy movement.
function enemy:start_walking()

  walking_movement = sol.movement.create("straight")
  walking_movement:set_speed(walking_speed)
  walking_movement:set_angle(math.random(4) * quarter)
  walking_movement:set_smooth(false)
  walking_movement:start(enemy)

  -- Take the obstacle normal as angle on obstacle reached.
  function walking_movement:on_obstacle_reached()
    walking_movement:set_angle(enemy:get_obstacles_normal_angle(walking_movement:get_angle()))
  end

  -- Regularly and randomly change the angle.
  sol.timer.start(enemy, keeping_angle_duration, function()
    if math.random(2) == 1 then
      walking_angle = 0 - walking_angle
    end
    return true
  end)

  -- Update walking angle, head sprite direction and tied sprites positions
  sol.timer.start(enemy, 10, function()
    walking_movement:set_angle((walking_movement:get_angle() + walking_angle) % circle)
    update_sprites()
    return walking_speed / walking_movement:get_speed() * 10 -- Schedule for each frame while walking and more while running, to keep the same curve and sprites distance.
  end)
end

-- Increase the enemy speed for some time.
function enemy:set_angry()

  is_angry = true
  walking_movement:set_speed(running_speed)
  sol.timer.start(enemy, angry_duration, function()
    is_angry = false
    walking_movement:set_speed(walking_speed)
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(4)
  enemy:set_size(24, 24)
  enemy:set_origin(12, 12)
  
  -- Create sprites in right z-order.
  sprites[5] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/moldorm_tail")
  for i = 3, 1, -1 do
    sprites[i + 1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/moldorm_body_" .. i)
  end
  sprites[1] = enemy:create_sprite("enemies/" .. enemy:get_breed())

  head_sprite = sprites[1]
  tail_sprite = sprites[5]
end)

enemy:register_event("on_enabled", function(enemy)
  if enemy:is_in_same_region(hero) then
    sol.timer.start(enemy, interval, function() sol.audio.play_sound("moldorm") return true end)
  end
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()
  enemy:set_hammer_reaction(on_attack_received)
  enemy:set_attack_consequence("sword", on_attack_received)

  enemy:set_arrow_reaction("protected")
  enemy:set_fire_reaction("protected")
  enemy:set_ice_reaction("protected")
  enemy:set_attack_consequence("explosion", "protected")
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_hookshot_reaction("protected")

  if enemy:is_in_same_region(hero) then
    sol.timer.start(enemy, interval, function() sol.audio.play_sound("moldorm") return true end)
  end

  -- States.
  last_positions = {}
  frame_count = 0
  is_angry = false
  enemy:set_can_attack(true)
  enemy:set_damage(0)
  enemy:start_walking()
  if enemy:get_life() < 4 then
    enemy:set_angry()
  end
end)

enemy:register_event("on_attacking_hero", function(enemy)
  local hero = enemy:get_map():get_hero()
	enemy:get_game():remove_life(2)
  hero:start_hurt(enemy, 1)
end)
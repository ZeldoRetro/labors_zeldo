-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls. This one is made of darkness.

local enemy = ...

local last_direction8 = 0

function enemy:on_created()
  self:set_life(1)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(8, 8)
  self:set_origin(4, 4)
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  enemy:set_ice_reaction("custom")
  self:set_powder_reaction(1)
end

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()
  local direction8 = math.random(4) * 2 - 1
  self:go(direction8)
end

-- An obstacle is reached: make the Bubble bounce.
function enemy:on_obstacle_reached()
  local dxy = {
    { x =  1, y =  0},
    { x =  1, y = -1},
    { x =  0, y = -1},
    { x = -1, y = -1},
    { x = -1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1}
  }

  -- The current direction is last_direction8:
  -- try the three other diagonal directions.
  local try1 = (last_direction8 + 2) % 8
  local try2 = (last_direction8 + 6) % 8
  local try3 = (last_direction8 + 4) % 8

  if not self:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
    self:go(try1)
  elseif not self:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
    self:go(try2)
  else
    self:go(try3)
  end
end

-- Makes the Bubble go towards a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)
  local m = sol.movement.create("straight")
  m:set_speed(80)
  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(self)
  last_direction8 = direction8
end

-- Bubbles have a specific attack which drains magic (and causes confusion).
function enemy:on_attacking_hero(hero,enemy_sprite)

  -- Hero loses 1/4 of his life
  local game = enemy:get_game()
  hero:start_hurt(enemy, 0)
  game:remove_life(math.floor(game:get_life() / 4))
end

function enemy:on_custom_attack_received(attack, enemy_sprite)
  if (attack == "ice") then
    enemy:create_enemy({ breed = "bubble_white" })
    enemy:remove()
  end
end
-- 3 fireballs shot by enemies like Zora and that go toward the hero.
-- They can be hit with the sword, this changes their direction.
local enemy = ...

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()
  enemy:set_minimum_shield_needed(2) -- Hylian shield.

  for i = 0, 2 do 
    sprites[#sprites + 1] = enemy:create_sprite("enemies/fireball_blue_small_circle")
  end
end

function enemy:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(144)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  -- Compute the coordinate offset of follower sprites.
  local x = math.cos(angle) * 10
  local y = -math.sin(angle) * 10
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)

  sprites[1]:set_animation("walking")
  sprites[2]:set_animation("following_1")
  sprites[3]:set_animation("following_2")

  movement:start(enemy)
end

-- Destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)

  local game = enemy:get_game()

  -- Hero is slowed.
  hero:start_hurt(enemy, 0)
  hero:set_walking_speed(48)
  sol.timer.start(3000, function() hero:set_walking_speed(88) end)
  enemy:remove()
end
local enemy = ...

-- A red flame shot by another enemy.

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/flame_purple")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_invincible(true)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
  enemy:set_minimum_shield_needed(2) -- Hylian shield.
end

function enemy:on_restarted()
  sol.timer.start(self, 1000, function()
    self:get_sprite():set_animation("disapear",function() 
      enemy:remove()
    end)
  end)
end

function enemy:go(angle)

  local m = sol.movement.create("straight")
  m:set_speed(144)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end

-- Remove 1/2 of life and destroy the flame when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)

  local game = enemy:get_game()
  hero:start_hurt(enemy, enemy_sprite, 0)
  game:set_life(math.floor(game:get_life() / 2))
  enemy:remove()
end
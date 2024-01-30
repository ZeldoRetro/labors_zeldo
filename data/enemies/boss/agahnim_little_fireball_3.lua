--Little fireball, division of blue fireballs sent by Agahnim

local enemy = ...

function enemy:on_created()
  self:set_life(1)
  self:set_damage(16)
  self:create_sprite("enemies/boss/agahnim_little_fireball")
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_optimization_distance(0)
  self:set_minimum_shield_needed(2) -- Hylian shield.
end

function enemy:on_obstacle_reached()
  enemy:remove()
end

function enemy:go(angle)
  local m = sol.movement.create("straight")
  m:set_speed(180)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end
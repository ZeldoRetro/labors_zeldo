local enemy = ...

-- Plasmarine ball: ball of electricity shot by Plasmarine

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/boss/1st_solarus_quest/plasmarine_ball")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
  self:set_invincible()
end

function enemy:on_movement_finished(movement)
  self:remove()
end

function enemy:on_restarted()
  local m = sol.movement.create("target")
  m:set_speed(24)
  m:set_ignore_obstacles(true)
  m:set_target(enemy:get_game():get_hero())
  m:start(self)

  sol.timer.start(enemy:get_game(),5000,function() enemy:remove() end)
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  -- the ball electrocutes the hero when it touches him
	hero:start_hurt(4)
  hero:freeze()
	hero:set_animation("electrocuted")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
end
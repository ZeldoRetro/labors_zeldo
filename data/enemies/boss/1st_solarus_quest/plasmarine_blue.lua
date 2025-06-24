local enemy = ...

-- Plasmarine: a boss which floats around shooting
--  electricity balls in order to electricute hero.

function enemy:on_created()
  self:set_life(8)
  self:set_damage(4)
  self:create_sprite("enemies/boss/1st_solarus_quest/plasmarine_blue")
  self:set_arrow_reaction(2)
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("explosion", 4)
  self:set_hookshot_reaction(4)
end

function enemy:on_restarted()
  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:shoot_ball() end)
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if enemy:get_sprite():get_animation() == "shaking" then
    hero:start_hurt(4)
    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("hero_hurt")
    sol.timer.start(1000, function () hero:unfreeze() end)
  else enemy:remove_life(1) end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  if enemy:get_sprite():get_animation() == "shaking" then
    hero:start_hurt(4)
    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("hero_hurt")
    sol.timer.start(1000, function () hero:unfreeze() end)
  else hero:start_hurt(4) end
end

function enemy:shoot_ball()
  enemy:get_sprite():set_animation("shaking")
  enemy:create_enemy({ breed = "boss/1st_solarus_quest/plasmarine_ball", direction = 0 })
  sol.timer.start(enemy:get_game(), 2000, function() enemy:restart() end)
end
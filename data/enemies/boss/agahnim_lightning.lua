--A deadly thunderbolt sent by Agahnim

local enemy = ...

function enemy:on_created()
  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_layer_independent_collisions(true)
  enemy:set_minimum_shield_needed(3) -- Mirror shield.
end

function enemy:on_restarted()
  sol.timer.start(enemy, 1000, function()
    enemy:remove()
  end)
end
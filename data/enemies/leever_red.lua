local enemy = ...

--Leever: Can disappear into the sand

function enemy:on_created()
  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attacking_collision_mode("overlapping")
  enemy:set_property("is_major","true")
  self:set_layer_independent_collisions(true)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  sol.timer.start(enemy, math.random(2000,4000), function() enemy:disappear() end)
  m:start(self)
end

function enemy:disappear()
  local sprite = self:get_sprite()
  sprite:set_animation("disappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_can_attack(false)
    enemy:set_invincible()
    sol.timer.start(enemy, math.random(3000,8000), function() enemy:reappear() end)
  end
end

function enemy:reappear()
  local sprite = self:get_sprite()
  enemy:set_can_attack(true)
  enemy:set_attack_consequence ("sword", 1)
  enemy:set_attack_consequence ("thrown_item", 1)
  enemy:set_attack_consequence ("explosion", 2)
  enemy:set_attack_consequence ("boomerang", "immobilized")
  enemy:set_hookshot_reaction("immobilized")
  enemy:set_fire_reaction(2)
  enemy:set_hammer_reaction(2)
  enemy:set_arrow_reaction(2)
  sprite:set_animation("appearing")
  function sprite:on_animation_finished(animation) enemy:restart() end
end
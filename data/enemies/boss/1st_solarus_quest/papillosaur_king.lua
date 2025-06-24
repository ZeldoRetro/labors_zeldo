local enemy = ...

function enemy:on_created()

  self:set_life(16)
  self:set_damage(2)
  self:set_push_hero_on_sword(true)
  self:set_pushed_back_when_hurt(false)
  self:set_arrow_reaction(1)
  self:set_attack_consequence("sword", "protected")
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(96, 92)
  self:set_origin(48, 76)
end

function enemy:on_restarted()
  local life = self:get_life() 
  if life <= 12 and life > 8 then
  	local n = sol.movement.create("path_finding")
  	n:set_speed(60)
        n:start(self)
  elseif life <= 8 and life > 4 then
  	local n = sol.movement.create("target")
  	n:set_speed(60)
        n:start(self)
  elseif life <= 4 then
  	local n = sol.movement.create("target")
  	n:set_speed(80)
        n:start(self)
  else
 	local m = sol.movement.create("path_finding")
  	m:set_speed(50)
  	m:start(self)
  end
end


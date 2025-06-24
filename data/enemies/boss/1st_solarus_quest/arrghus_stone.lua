local enemy = ...
local speed = 16

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye to be hurt

function enemy:on_created()
  self:set_life(16)
  self:set_damage(4)
  self:set_push_hero_on_sword(true)
  self:set_pushed_back_when_hurt(false)
  self:create_sprite("enemies/boss/arrghus_stone")
  self:set_hurt_style("boss")
  self:set_size(56, 64)
  self:set_origin(28, 56)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  self:set_attack_consequence("explosion", 2)
  self:set_attack_consequence("sword", "protected")
  self:set_arrow_reaction("protected")
  self:get_sprite():set_animation("walking")
end

function enemy:on_restarted()
  if self:get_life() > 0 then 
    self:set_attack_consequence("explosion", 2)
    local m = sol.movement.create("circle")
    m:set_center(enemy:get_game():get_map():get_entity("heart_container_spot"):get_position())
    m:set_radius(192)
    m:set_initial_angle(math.pi / 2)
    m:set_angle_speed(speed)
    m:set_ignore_obstacles(true)
    m:start(self)
  end
end

function enemy:on_hurt()
  speed = speed + 4
end
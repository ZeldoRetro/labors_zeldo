local enemy = ...
local vanilla_spot = enemy:get_map():get_entity(enemy:get_name().."_vanilla_spot")
local sleep_beginning = true
local going_timer = 1500
local going = false
local turning_back = false

--Vitreous Mini

function enemy:on_created()

  self:set_life(16)
  self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()
  if sleep_beginning then self:sleep()
  elseif turning_back then self:turn_back()
  elseif going then going_timer = 500 self:go()
  end
end

function enemy:sleep()
  self:get_sprite():set_animation("sleeping")
  self:set_can_attack(false)
  self:set_invincible()
  sol.timer.start(enemy,math.random(1200,2500),function()
    if enemy:is_in_same_region(enemy:get_map():get_hero()) and enemy:get_distance(enemy:get_map():get_hero()) < 144 then
      sleep_beginning = false
      enemy:go() 
    else enemy:sleep() end
  end)
end

function enemy:go()
  going = true
  self:get_sprite():set_animation("walking")
  self:set_arrow_reaction(8)
  self:set_hammer_reaction(4)
  self:set_fire_reaction(2)
  self:set_ice_reaction(2)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 2)
  self:set_attack_consequence("explosion", 2)
  self:set_can_attack(true)
  self:set_traversable(true)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  self:set_can_attack(true)
  sol.audio.play_sound("cape_off")
  m:start(self)
  sol.timer.start(enemy,going_timer,function() going = false going_timer = 1500 enemy:turn_back() end)
end

function enemy:turn_back()
  turning_back = true
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:set_target(vanilla_spot)
  m:start(self,function() turning_back = false enemy:sleep() end)
end
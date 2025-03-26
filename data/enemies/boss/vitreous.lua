local enemy = ...
local enemy_going = false

--Vitreous

function enemy:on_created()

  self:set_life(24)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_pushed_back_when_hurt(false)
end

function enemy:on_enabled()
  enemy:get_map():set_entities_enabled("vitreous_mini",true)
end

function enemy:on_restarted()
  self:get_sprite():set_animation("sleeping")
  self:set_can_attack(false)
  self:set_invincible()
  if enemy_going then self:go(enemy) end
  sol.timer.start(enemy,math.random(4000,6000),function() 
    if enemy_going then self:go(enemy) else self:lightning_attack() end
  end)
end

function enemy:on_hurt()
  if enemy:get_life() <= 0 then enemy:get_map():set_entities_enabled("vitreous_mini",false) end
end

function enemy:lightning_attack()
  self:get_sprite():set_animation("walking")
  self:set_arrow_reaction(8)
  self:set_hammer_reaction(4)
  self:set_fire_reaction(2)
  self:set_ice_reaction(2)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 2)
  self:set_attack_consequence("explosion", 2)
  self:set_can_attack(true)
  sol.timer.start(enemy,600,function()
    sol.audio.play_sound("laser")
    enemy:create_enemy({
      breed = "boss/agahnim_lightning",
      direction = math.random(0,3),
      layer = 2,
    })
    sol.timer.start(enemy,500,function() enemy:restart() end)
  end)
end

function enemy:go(enemy)
  enemy_going = true
  self:get_sprite():set_animation("walking")
  self:set_arrow_reaction(8)
  self:set_hammer_reaction(4)
  self:set_fire_reaction(2)
  self:set_ice_reaction(2)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 2)
  self:set_attack_consequence("explosion", 2)
  self:set_can_attack(true)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  self:set_can_attack(true)
  m:start(self)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end
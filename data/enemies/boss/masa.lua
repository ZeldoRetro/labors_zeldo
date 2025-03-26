local enemy = ...

local speed = 32
local timer1 = 3000
local timer2 = 5000

--Masa Boss

function enemy:on_created()

  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_pushed_back_when_hurt(false)
end

local function shoot()

  local sprite = enemy:get_sprite()

  

  enemy:stop_movement()
  sprite:set_animation("shooting")
  sol.audio.play_sound("laser")
  sol.timer.start(enemy, 120, function()
    local projectile = enemy:create_enemy({breed = "fireball_red_small",layer = 2})
    enemy:restart()
  end)

end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local m = sol.movement.create("path_finding")
  m:set_speed(speed)
  m:start(self)

  sol.timer.start(enemy,math.random(timer1,timer2),function() shoot() end)
end

function enemy:on_hurt()
  speed = speed + 8
  timer1 = timer1 - 1000
  timer2 = timer2 - 1000
end
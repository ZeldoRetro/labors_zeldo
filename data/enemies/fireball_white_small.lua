--Ice balls: Freeze the hero

local enemy = ...
local map = enemy:get_map()

local speed = 128
local custom_target = false
local target = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(0)
  self:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()
  enemy:set_minimum_shield_needed(2) -- Hylian shield.
  enemy:set_property("is_major","true")

  for _, prop in ipairs(self:get_properties()) do
    if prop.key == "target_x" then
      custom_target = true
      target.x = tonumber(prop.value)
    elseif prop.key == "target_y" then
      custom_target = true
      target.y = tonumber(prop.value)
    end
  end
end

function enemy:on_restarted()

  local target_x = 0
  local target_y = 0

  if custom_target == true then
    target_x = target.x
    target_y = target.y
  else
    target_x, target_y = self:get_map():get_entity("hero"):get_position()
  end
  
  local angle = self:get_angle(target_x, target_y - 5)
  local m = sol.movement.create("straight")
  m:set_speed(speed)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)

  sol.timer.start(enemy, 80, function()
    local x, y, layer = enemy:get_position()
    local following = map:create_custom_entity({
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      width = 8,
      height = 8,
      sprite = "enemies/fireball_white_small",
    })
    local sprite = following:get_sprite()
    sprite:set_animation("destroying")
    sprite.on_animation_finished = function(animation)
      if animation == "destroying" then
        enemy:remove()
      end
    end
    return true
  end)
end

function enemy:on_obstacle_reached()
  self:remove()
end

-- Destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(7)
  hero:start_hurt(enemy, 1)
  hero:freeze()
	hero:set_animation("frozen")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
  enemy:remove()
end
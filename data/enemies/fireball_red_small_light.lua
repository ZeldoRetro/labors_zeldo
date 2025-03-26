--Fire balls

local enemy = ...
local map = enemy:get_map()

local speed = 128
local custom_target = false
local target = {}

require("scripts/fsa_effect")
local el = create_light(map,-256,-256,0,"80","240,210,15")

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(0)
  self:create_sprite("enemies/fireball_red_small")
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

  function el:on_update()
    el:set_position(enemy:get_position())
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
      sprite = "enemies/fireball_red_small",
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

function enemy:on_removed()
  el:set_enabled(false)
end

-- Destroy the fireball when the hero is touched.
enemy:register_event("on_attacking_hero", function(enemy)
  local hero = enemy:get_map():get_hero()
	enemy:get_game():remove_life(2)
  hero:start_hurt(enemy, 1)
  enemy:remove()
end)
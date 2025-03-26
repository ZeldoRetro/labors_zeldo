--Fire balls

local enemy = ...
local map = enemy:get_map()

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()
  enemy:set_minimum_shield_needed(2) -- Hylian shield.
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(96)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  movement:start(enemy)
end

function enemy:on_restarted()

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())
  go(angle)
end

-- Destroy the fireball when the hero is touched.
enemy:register_event("on_attacking_hero", function(enemy)
  enemy:remove()
end)
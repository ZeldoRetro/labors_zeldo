----------------------------------
--
-- Add zol behavior to an ennemy.
--
-- Usage : 
-- local my_enemy = ...
-- local behavior = require("enemies/lib/zol")
-- local properties = {}
-- behavior.apply(my_enemy, properties)
--
----------------------------------

-- Global variables
local behavior = {}
require("scripts/multi_events")

function behavior.apply(enemy, properties)

  require("enemies/lib/common_actions").learn(enemy)

  local map = enemy:get_map()
  local hero = map:get_hero()
  local sprite = properties.sprite

  -- Configuration variables
  local walking_speed = properties.walking_speed or 4
  local jumping_speed = properties.jumping_speed or 64
  local jumping_height = properties.jumping_height or 12
  local jumping_duration = properties.jumping_duration or 600
  local attack_triggering_distance = properties.attack_triggering_distance or 64
  local shaking_duration = properties.shaking_duration or 1000
  local exhausted_minimum_duration = properties.exhausted_minimum_duration or 2000
  local exhausted_maximum_duration = properties.exhausted_maximum_duration or 4000

  -- Start moving to the hero, and jump when he is close enough.
  function enemy:start_walking()
    
    local movement = enemy:start_target_walking(hero, walking_speed)
    function movement:on_position_changed()
      if not enemy.is_attacking and not enemy.is_exhausted and enemy:is_near(hero, attack_triggering_distance) then
        enemy.is_attacking = true
        movement:stop()
        
        -- Shake for a short duration then start attacking.
        sprite:set_animation("shaking")
        sol.timer.start(enemy, shaking_duration, function()
           enemy:start_jump_attack(true)
        end)
      end
    end
  end

  -- Event triggered when the enemy is close enough to the hero.
  function enemy:start_jump_attack(offensive)

    -- Start jumping to the hero.
    local hero_x, hero_y, _ = hero:get_position()
    local enemy_x, enemy_y, _ = enemy:get_position()
    local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x) + (offensive and math.pi or 0)
    enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed)
    sprite:set_animation("jump")
  end

  -- Stop being exhausted after a minimum delay + random time
  function enemy:schedule_exhausted_end()

    sol.timer.start(enemy, math.random(exhausted_minimum_duration, exhausted_maximum_duration), function()
      enemy.is_exhausted = false
    end)
  end

  -- Restart settings.
  enemy:register_event("on_restarted", function(enemy)

    -- States.
    enemy.is_attacking = false
    enemy.is_exhausted = true
    enemy:schedule_exhausted_end()
  end)
end

return behavior

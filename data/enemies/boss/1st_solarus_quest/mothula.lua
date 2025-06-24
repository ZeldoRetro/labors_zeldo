-- Mowathula boss.

local enemy = ...

function enemy:on_created()

  self:set_life(64)
  self:set_damage(4)
  self:create_sprite("enemies/boss/mothula")
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_size(32, 32)
  self:set_origin(16, 16)
  self:set_push_hero_on_sword(true)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_arrow_reaction(2)
  self:set_attack_consequence("explosion", 1)
  self:set_attack_consequence("thrown_item", 1)

  enemy:set_shooting(true)
end

function enemy:on_restarted()

  local life = self:get_life() 
  local movement = sol.movement.create("path_finding")
  if life <= 12 and life > 8 then
  	movement:set_speed(48)
  elseif life <= 8 and life > 4 then
  	movement:set_speed(64)
  elseif life <= 4 then
  	movement:set_speed(72)
  else
  	movement:set_speed(36)
  end
  movement:start(enemy)

  local map = enemy:get_map()
  local hero = map:get_hero()
  sol.timer.start(enemy, 5000, function()
    if not enemy.shooting then
      return true
    end
    if enemy:get_distance(hero) < 500 and enemy:is_in_same_region(hero) then

      if not map.medusa_recent_sound then
        sol.audio.play_sound("boss_fireball")
        -- Avoid loudy simultaneous sounds if there are several medusa.
        map.medusa_recent_sound = true
        sol.timer.start(map, 200, function()
          map.medusa_recent_sound = nil
        end)
      end

      enemy:create_enemy({
        breed = "boss/agahnim_red_fireball",
        layer = 2,
      })
    end
    return true  -- Repeat the timer.
  end)
end

-- Suspends or restores shooting fireballs.
function enemy:set_shooting(shooting)
  enemy.shooting = shooting
end



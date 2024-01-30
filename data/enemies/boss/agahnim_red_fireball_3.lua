--A strong fireball you can return to Agahnim

local enemy = ...

local used_sword = false

function enemy:on_created()
  self:set_life(1)
  self:set_damage(32)
  self:create_sprite("enemies/boss/agahnim_red_fireball")
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  self:set_attack_consequence("sword", "custom")
  self:set_minimum_shield_needed(3) -- Mirror shield.
end

function enemy:on_restarted()

  local hero_x, hero_y = self:get_map():get_entity("hero"):get_position()
  local angle = self:get_angle(hero_x, hero_y - 5)
  local m = sol.movement.create("straight")
  m:set_speed(180)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" then
    local hero_x, hero_y = self:get_map():get_entity("hero"):get_position()
    local angle = self:get_angle(hero_x, hero_y - 5) + math.pi
    local m = sol.movement.create("straight")
    m:set_speed(144)
    m:set_angle(angle)
    m:set_smooth(false)
    m:start(self)
    sol.audio.play_sound("boss_fireball")
    used_sword = true
  end
end

function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
  if used_sword then
    if other_enemy.receive_bounced_fireball ~= nil then
      other_enemy:receive_bounced_fireball(self)
    end
  end
end
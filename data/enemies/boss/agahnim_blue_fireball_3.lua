--A blue fireball who divides in 8 once hitting an obstacle

local enemy = ...

function enemy:on_created()

  self:set_life(1)
  self:set_damage(16)
  self:create_sprite("enemies/boss/agahnim_blue_fireball")
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  self:set_attack_consequence("sword", "custom")
  self:set_minimum_shield_needed(3) -- Mirror shield.
end

function enemy:on_restarted()
  local x, y = self:get_position()
  local hero_x, hero_y = self:get_map():get_entity("hero"):get_position()
  local angle = self:get_angle(hero_x, hero_y - 5)
  local m = sol.movement.create("straight")
  m:set_speed(180)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end

local i

local function fireball_explode()
  if i < 8 then
    i = i + 1
    local angle_start = 1 * math.pi / 4
    local angle_end = 9 * math.pi / 4
    local angle = angle_start + i * (angle_end - angle_start) / 8
    local fireball = enemy:create_enemy({
      breed = "boss/agahnim_little_fireball_3",
    })
    fireball:go(angle)
    fireball_explode()
  end
end

function enemy:on_obstacle_reached(movement)
  i = 0
  fireball_explode()
  sol.audio.play_sound("boss_fireball")
  enemy:remove()
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" then
    i = 0
    fireball_explode()
    sol.audio.play_sound("boss_fireball")
    enemy:remove()
  end
end
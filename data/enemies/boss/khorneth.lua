local enemy = ...

-- The boss Khorneth from @PyroNet.
-- Khorneth has two blades that must be destroyed first.

-- State.
local left_blade_life = 4
local right_blade_life = 4
local blade_attack = false

local final_phase = false
local speed = 48
local delay = 1200

-- Sprites.
local main_sprite = enemy:create_sprite("enemies/boss/khorneth")
local left_blade_sprite = enemy:create_sprite("enemies/boss/khorneth_left_blade")
local right_blade_sprite = enemy:create_sprite("enemies/boss/khorneth_right_blade")
-- When a blade sprite has the same animation than the
-- main sprite, synchronize their frames
left_blade_sprite:synchronize(main_sprite)
right_blade_sprite:synchronize(main_sprite)
enemy:set_size(48, 32)
enemy:set_origin(24, 29)

-- Properties.
enemy:set_life(32)
enemy:set_damage(8)
enemy:set_hurt_style("boss")
enemy:set_pushed_back_when_hurt(false)
enemy:set_push_hero_on_sword(true)
enemy:set_invincible()
enemy:set_attack_consequence("sword", "protected")
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("thrown_item", "protected")
enemy:set_arrow_reaction("custom")
enemy:set_hookshot_reaction("protected")
enemy:set_hammer_reaction("protected")
enemy:set_fire_reaction("protected")
enemy:set_ice_reaction("protected")
enemy:set_attack_consequence("explosion", "protected")

function main_sprite:on_animation_finished(animation)
  if blade_attack then
    blade_attack = false
    enemy:restart()
  end
end

function enemy:on_restarted()

  local direction4 = main_sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(speed)
  m:set_loop(true)
  m:start(self)

  if final_phase then
    m = sol.movement.create("target")
    m:set_speed(64)
    m:start(self)
  end

  -- Schedule a blade attack
  if self:has_blade() then
    sol.timer.start(self, delay, function() self:start_blade_attack() end)
    blade_attack = false
  end
end

function enemy:has_left_blade()
  return left_blade_life > 0
end

function enemy:has_right_blade()
  return right_blade_life > 0
end

function enemy:has_blade()
  return self:has_left_blade() or self:has_right_blade()
end

-- The enemy receives an attack whose consequence is "custom".
function enemy:on_custom_attack_received(attack, sprite)

  if self:has_left_blade() then

    left_blade_life = left_blade_life - 1
    self:stop_hurting_left_blade()
    enemy:hurt(1)


  elseif self:has_right_blade() then

    right_blade_life = right_blade_life - 1
    self:stop_hurting_right_blade()
    enemy:hurt(1)

  end

end

function enemy:on_obstacle_reached()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  sprite:set_direction((direction4 + 2) % 4)

  local hero = self:get_map():get_hero()

  recent_obstacle = 8
  self:restart()
end

function enemy:start_blade_attack()

  if self:has_blade() and not blade_attack then

    blade_attack = true
    local side
    if not self:has_right_blade() then
      side = 0
    elseif not self:has_left_blade() then
      side = 1
    else
      side = math.random(2) - 1
    end

    if side == 0 then
      animation = "left_blade_attack"
    else
      animation = "right_blade_attack"
    end

    main_sprite:set_animation(animation)
    if self:has_left_blade() then
      left_blade_sprite:set_animation(animation)
    end
    if self:has_right_blade() then
      right_blade_sprite:set_animation(animation)
    end

    sol.audio.play_sound("octorok")
    local stone = enemy:create_enemy({
      breed = "octorok_stone",
      layer = 2,
      x = 0,
      y = -16,
    })

    stone:go(3)
    stone:set_layer_independent_collisions(true)

    self:stop_movement()
  end
end

function enemy:stop_hurting_left_blade()

  self:restart()
  if left_blade_life <= 0 then
    sol.audio.play_sound("stone")
    self:remove_sprite(left_blade_sprite)

    enemy:get_map():get_entity("pike_1"):set_enabled(true)

    if not self:has_right_blade() then
      self:start_final_phase()
    end
  end
end

function enemy:stop_hurting_right_blade()

  self:restart()
  if right_blade_life <= 0 then
    sol.audio.play_sound("stone")
    self:remove_sprite(right_blade_sprite)

    if not self:has_left_blade() then
      self:start_final_phase()
    end
  end
end

function enemy:on_hurt()
  speed = speed + 4
  delay = delay - 50
end

function enemy:start_final_phase()
  final_phase = true
  self:get_game():get_map():set_entities_enabled("phase_1_wall_",false)
  self:set_attack_consequence("sword", 1)
  self:set_arrow_reaction(4)
  self:get_map():get_entity("pike_1"):set_enabled(false)

  m = sol.movement.create("target")
  m:set_speed(48)
  m:start(self)
end


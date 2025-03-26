local enemy = ...

-- Pike that always moves, horizontally or vertically
-- depending on its direction.

local recent_obstacle = 0

local speed = 40
local timer = 2000
local m
local stunned = false

function enemy:on_created()

  self:set_life(6)
  enemy:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_hurt_style("boss")
  self:set_can_hurt_hero_running(true)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "custom")
end

function enemy:on_enabled()
  enemy:get_map():get_entity("gohma"):set_enabled(true)
end

local function open_eye()
  local hero = enemy:get_map():get_hero()
    stunned = true
    m:stop()
    enemy:get_sprite():set_animation("immobilized")
    enemy:set_arrow_reaction(1)
    sol.timer.start(1200, function ()
      if enemy:get_sprite():get_animation() == "immobilized" then
        sol.audio.play_sound("zora")
        enemy:create_enemy({
        breed = "fireball_red_small",
        layer = 1
        })
      end
      stunned = false
      enemy:set_arrow_reaction("protected")
      enemy:restart()
    end)
end

function enemy:on_restarted()

  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "custom")
  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(speed)
  m:set_loop(true)
  m:start(self)
  sol.timer.start(enemy,timer,function()
    if not stunned then
      open_eye()
    end
  end)
end

function enemy:on_custom_attack_received(attack, sprite)
  local hero = enemy:get_map():get_hero()
  if attack == "explosion" then
    stunned = true
    m:stop()
    enemy:get_sprite():set_animation("immobilized")
    enemy:set_arrow_reaction(1)
    sol.timer.start(3000, function ()
      stunned = false
      enemy:set_arrow_reaction("protected")
      enemy:restart()
    end)
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

function enemy:on_position_changed()

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end

function enemy:on_hurt()
  stunned = false
  speed = speed + 16
  timer = timer - 200
  enemy:get_map():get_entity("gohma"):hurt(1)
end
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local transformation_effect = map:get_entity("transformation_effect")

local boss_phase_1 = true


function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_invincible()
  self:set_hurt_style("boss")
  self:set_can_hurt_hero_running(true)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_fire_reaction("protected")
  self:set_ice_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_hammer_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "protected")
  enemy:set_life(6)
  enemy:set_damage(8)
end

function enemy:explode()
  movement:stop()
  local x, y, layer = enemy:get_position()
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sol.audio.play_sound("cape_off")
  transformation_effect:set_enabled(true)
  transformation_effect:get_sprite():set_frame(0)
  transformation_effect:set_position(x, y - 4, layer + 1)
  sol.timer.start(enemy,280,function()
    enemy:set_visible(false)
    map:get_entity("digdogger_mini_1"):set_position(enemy:get_position())
    map:get_entity("digdogger_mini_2"):set_position(enemy:get_position())
    map:get_entity("digdogger_mini_3"):set_position(enemy:get_position())
    map:get_entity("digdogger_mini_4"):set_position(enemy:get_position())
    map:get_entity("digdogger_mini_5"):set_position(enemy:get_position())
    map:get_entity("digdogger_mini_6"):set_position(enemy:get_position())
  end)
end

function enemy:on_restarted()

  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(32)
  movement:start(enemy)
end

function enemy:on_hurt()
  enemy:set_visible(true)
end
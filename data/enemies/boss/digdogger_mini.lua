local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement


function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_can_hurt_hero_running(true)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  enemy:set_life(6)
  enemy:set_damage(4)
end

function enemy:on_restarted()

  movement = sol.movement.create("random")
  movement:set_speed(64)
  movement:start(enemy)
end

function enemy:on_dead()
  map:get_entity("boss"):set_life(map:get_entity("boss"):get_life() - 1)
end

function enemy:on_dying()
  if map:get_entity("boss"):get_life() == 1 then
    enemy:set_enabled(false)
    map:get_entity("boss"):set_visible(true)
    map:get_entity("boss"):set_position(enemy:get_position())
    map:get_entity("boss"):hurt(1)
  end
end
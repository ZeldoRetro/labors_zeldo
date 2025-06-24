--Basic Ganon: just a simple enemy who targets you

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(128)
  enemy:set_damage(48)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/boss/ganon")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_invincible()

  enemy:set_attack_consequence("sword", 1)
  if game:has_item("inventory/bow_light") then
    enemy:set_arrow_reaction(8)
  end
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(72)
  movement:start(enemy)
end
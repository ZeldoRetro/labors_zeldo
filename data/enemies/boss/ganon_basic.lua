--Basic Ganon: just a simple enemy who targets you

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(64)
  enemy:set_damage(16)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/boss/ganon")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_invincible()

  if game:get_value("get_master_sword") then
    enemy:set_attack_consequence("sword", 1)
  else
    enemy:set_attack_consequence("sword", "protected")
  end
  if game:has_item("inventory/bow_light") then
    enemy:set_arrow_reaction(2)
  end
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(enemy)
end
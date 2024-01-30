--Bari green

local enemy = ...

local bari_mixin = require 'enemies/bari_mixin_circle'

function enemy:on_created()
  self:set_life(2)
  self:set_damage(2)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
  enemy:set_attack_consequence("explosion", 2)
  enemy:set_attack_consequence("boomerang", "ignored")
  enemy:set_attack_consequence("thrown_item", 1)
  enemy:set_arrow_reaction(2)
  enemy:set_hookshot_reaction(2)
  enemy:set_fire_reaction("ignored")
  enemy:set_ice_reaction("ignored")
  enemy:set_hammer_reaction(4)
  self:create_sprite("enemies/bari_green")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_pushed_back_when_hurt(false)
  enemy:set_layer(self:get_layer() + 1)
  enemy:set_layer_independent_collisions(true)
  bari_mixin.mixin(self)
end
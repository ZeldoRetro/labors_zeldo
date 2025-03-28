--Bari green

local enemy = ...

local bari_mixin = require 'enemies/bari_mixin'

function enemy:on_created()
  self:set_life(2)
  self:set_damage(2)
  self:set_hookshot_reaction(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attacking_collision_mode("overlapping")
  self:set_obstacle_behavior("flying")
  bari_mixin.mixin(self)
end
local enemy = ...

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()


function enemy:on_created()

  self:set_life(16)
  self:set_damage(16)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attacking_collision_mode("overlapping")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
end

function enemy:on_restarted()

  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end
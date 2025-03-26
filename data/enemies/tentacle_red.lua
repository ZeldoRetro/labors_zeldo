local enemy = ...

--Tentacle red

function enemy:on_created()

  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attacking_collision_mode("overlapping")
end

function enemy:on_restarted()

  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
end
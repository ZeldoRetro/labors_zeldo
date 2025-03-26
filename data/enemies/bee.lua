local enemy = ...

--Tentacle blue

function enemy:on_created()

  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(8, 8)
  self:set_origin(4, 6)
end

function enemy:on_restarted()

  local m = sol.movement.create("random")
  m:set_speed(96)
  m:start(self)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end
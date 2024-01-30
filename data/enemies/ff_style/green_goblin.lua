local enemy = ...

--Tentacle blue

function enemy:on_created()

  self:set_life(4)
  self:set_damage(1)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()

end
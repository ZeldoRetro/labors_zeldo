local item = ...
local can_use_bomb = true

function item:on_created()

  self:set_savegame_variable("possession_ally_bomb_throw")
  self:set_assignable(true)
end

-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
function item:on_using()

  if can_use_bomb then
    self:throw_bomb()
    can_use_bomb = false
    sol.timer.start(item, 1000, function() can_use_bomb = true end)
    self:set_finished()
  else
    self:set_finished()
  end
end

function item:throw_bomb()
  local hero = item:get_map():get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  local angle = direction * math.pi / 2

  hero:freeze()
  hero:set_animation("shooting")
  sol.timer.start(item, 200, function()
    hero:set_animation("stopped")
    local projectile = item:get_map():create_enemy({layer = layer + 1,
                                                    x = x,
                                                    y = y,
                                                    direction = direction,
                                                    breed = "ally/bomb"})
    projectile:go(250, nil, angle, 240)
    hero:unfreeze()
  end)

end
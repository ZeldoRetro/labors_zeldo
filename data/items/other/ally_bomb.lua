local item = ...
local can_use_bomb = true

function item:on_created()

  self:set_savegame_variable("possession_ally_bomb")
  self:set_assignable(true)
end

-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
function item:on_using()

  if can_use_bomb then
    self:create_bomb()
    sol.audio.play_sound("bomb")
    can_use_bomb = false
    sol.timer.start(item, 1000, function() can_use_bomb = true end)
    self:set_finished()
  else
    self:set_finished()
  end
end

function item:create_bomb()
  local hero = item:get_map():get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 16
  elseif direction == 1 then
    y = y - 16
  elseif direction == 2 then
    x = x - 16
  elseif direction == 3 then
    y = y + 16
  end

  item:get_map():create_enemy({
    name = "viscen_bomb",
    layer = layer,
    x = x,
    y = y,
    direction = 0,
    breed = "ally/bomb"
  })
end
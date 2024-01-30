-- Lua script of item "bombs counter".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()
local hero = game:get_hero()

-- Event called when the game is initialized.
function item:on_created()

  self:set_savegame_variable("possession_bombs_counter")
  self:set_amount_savegame_variable("amount_bombs_counter")
  self:set_assignable(true)

end

function item:on_using()
  item:start_using()
  item:set_finished()
end


-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
function item:start_using()
  if item:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  elseif game:get_hero():get_sprite():get_animation() == "carrying_stopped" or game:get_hero():get_sprite():get_animation() == "carrying_walking" or game:get_hero():get_sprite():get_animation() == "lifting" then
    return
  else
    local hero=item:get_game():get_hero()
      item:remove_amount(1)
      local map = item:get_map()
      local x, y, layer = hero:get_position()
      local direction4 = hero:get_direction()
      local bomb = map:create_custom_entity({
        model = "bomb",
        sprite = "entities/bomb",
        direction = 0,
        x = x + (direction4 == 0 and 16 or direction4 == 2 and -16 or 0),
        y = y + (direction4 == 1 and -16 or direction4 == 3 and 16 or 0),
        layer = layer,
        width = 16,
        height = 16
      })
  end
  item:set_finished()

end

function item:remove_bombs_on_map()

  local map = item:get_map()
  if map.current_bombs == nil then
    return
  end
  for bomb in pairs(map.current_bombs) do
    bomb:remove()
  end
  map.current_bombs = {}

end
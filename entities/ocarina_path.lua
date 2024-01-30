local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Ocarina path: a special map entity that allows the hero
-- to warp to a paired point if he has the Flight Song

function entity:on_created()
  self:set_traversable_by(true)
  self.action_effect = "look"
end

function entity:on_interaction()
  -- If this point not previously discovered then add it.
  if not game:get_value(entity:get_name()) then
    game:start_dialog("ocarina_path.new_point", function()
      game:set_value(entity:get_name(), true)
      self:get_sprite():set_animation("linked")
    end)
  else
    game:start_dialog("ocarina_path.interaction")
  end
end
local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  snores:set_enabled(false)
end
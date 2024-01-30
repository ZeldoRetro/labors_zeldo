-- Variables
local map = ...
local game = map:get_game()
require("maps/lib/sideview_manager")

-- Map events
function map:on_started()
  -- Sideview
  map:set_sideview(true)

end
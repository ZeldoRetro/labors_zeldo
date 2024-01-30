local map = ...
local game = map:get_game()

function map:on_started()

  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
  hero:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
end

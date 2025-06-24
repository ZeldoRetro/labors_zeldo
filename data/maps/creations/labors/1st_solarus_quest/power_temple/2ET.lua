local map = ...
local game = map:get_game()

-- COFFRES VIDES
function chest_empty_1:on_opened()
    sol.audio.play_sound("treasure_bad")
	game:start_dialog("_empty_chest")
	hero:unfreeze()
end
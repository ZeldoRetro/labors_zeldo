local map = ...
local game = map:get_game()

function map:on_started()
  if game:get_value("labors_tott_minigame_hookshot_stolen") then steal_sensor:set_enabled(false) end
end

function steal_sensor:on_activated()
  if game:get_value("labors_tott_minigame_hookshot_stolen") then
    sol.audio.play_music("none")
    game:start_dialog("LABORS.tott.abuda.minigame_hookshot_steal",function()
      game:set_life(0)
    end)
  end
end
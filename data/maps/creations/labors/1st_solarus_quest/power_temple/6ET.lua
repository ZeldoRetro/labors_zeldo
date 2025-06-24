local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)
  -- Pas de musique près du boss
  if destination == escalier_n or destination == telep_boss_entree or destination == escalier_boss then
    sol.audio.play_music("none")
  end
end)
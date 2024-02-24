local map = ...
local game = map:get_game()

function map:on_started()
  os.execute("start https://www.youtube.com/watch?v=8gGiGWdB9-Y")
  sol.timer.start(map,100,function() hero:teleport("creations/labors/tott/dungeon_of_requirement_D8","front_ts","immediate") end)
end
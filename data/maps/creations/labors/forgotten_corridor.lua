local map = ...
local game = map:get_game()

local function look_frame(frame_dialog, test_image)
  game:start_dialog(frame_dialog,function()
    test_image:fade_in(30,function()
      game:start_dialog("empty", function()
        test_image:fade_out(50, function()
          hero:unfreeze()
          function sol.video:on_draw(screen) end
        end)
      end)
    end)
    function sol.video:on_draw(screen)
      local x_size_1, y_size_1 = sol.video.get_window_size()
      local x_size_2, y_size_2 = test_image:get_size()
      local calcul = 1
      if x_size_1 < y_size_1 then
        calcul = x_size_1/x_size_2
      else
        calcul = y_size_1/y_size_2
      end
      test_image:set_scale(calcul, calcul)
      test_image:draw(screen, 0, 0)
    end
  end)
end

for npc in map:get_entities("npc_frame_") do
  function npc:on_interaction()
    hero:freeze()
    look_frame(npc:get_property("dialog"),sol.surface.create(npc:get_property("image")))
  end
end

--GLITCH VERS ???
function glitch_transition:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.audio.play_music("none")
  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
  map:set_tileset("outside_main")
  sol.audio.play_sound("glitch_transition")
  print("Tu n'aurais pas dû faire ça.")
  sol.timer.start(map,100,function()
    map:set_tileset("outside_buildings")
    sol.audio.play_sound("glitch_transition")
    print("TU N AURAIS PAS DU FAIRE CA")
    sol.timer.start(map,100,function()
      map:set_tileset("inside_red_dungeon")
      sol.audio.play_sound("glitch_transition")
      print("T U  N  A U R A I S  P A S  D U  F A I R E  C A")
      sol.timer.start(map,100,function()
        map:set_tileset("outside_special")
        sol.timer.start(map,100,function()
          hero:teleport("creations/labors/FORBIDDEN_ACCESS","destination","immediate")
        end)
      end)
    end)
  end)
end

function map:on_finished()
  function sol.video:on_draw(screen) end
end
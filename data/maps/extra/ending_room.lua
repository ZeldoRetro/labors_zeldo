-- Lua script of map extra/ending_room.

local map = ...
local game = map:get_game()
local hero = map:get_hero()

local light_screen
light_screen = sol.surface.create(320, 240)
light_screen:fill_color({200, 85, 255, 255})
light_screen:fade_out(0)

function map:on_started()

end

function map:on_opening_transition_finished()

end

function sensor:on_activated()
  hero:freeze()
  game:set_dialog_style("blank")
  game:start_dialog("razdarac", function()
    sol.audio.play_sound("laser")
    light_screen:fade_in(10, function()
      razdarac_1:remove()
      razdarac_2:remove()
      light_screen:fade_out(10, function()
        hero:unfreeze()
        sensor:remove()
      end)
    end)
  end)
end

function map:on_draw(dst_surface)
	light_screen:draw(dst_surface)
end

--REGARDER LE PORTRAIT

local function look_frame(frame_dialog, test_image)
  game:start_dialog(frame_dialog,function()
    game:set_pause_allowed(false)
    test_image:fade_in(30,function()
      game:start_dialog("empty", function()
        test_image:fade_out(50, function()
          game:set_pause_allowed(true)
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

function map:on_finished()
  function sol.video:on_draw(screen) end
end
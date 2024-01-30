local presentation_screen = {}

local presentation_img = sol.surface.create("menus/presentation.png")

local background_img = sol.surface.create(320,240)
background_img:fill_color({255,255,255})

function presentation_screen:on_started()
  sol.audio.play_sound("intro")
  sol.timer.start(presentation_screen,2000,function() presentation_img:fade_out(20,function() sol.menu.stop(presentation_screen) end) end)
end

function presentation_screen:on_draw(dst_surface)
  background_img:draw(dst_surface)
  presentation_img:draw(dst_surface)
end

return presentation_screen
--Title screen

local title_screen = {}
local is skipping = false
local is_fading = false
local space = false
  
local logo_img = sol.surface.create("menus/title_labors_logo.png")
local gamepad_img = sol.surface.create("menus/title_labors_gamepad.png")
local zeldo_img = sol.surface.create("menus/title_labors_zeldo.png")
local frames_img = sol.surface.create("menus/title_labors_frames_2.png")
local background_img = sol.surface.create(320,240)
background_img:fill_color({255,255,255})
local background_slabs_img = sol.surface.create("menus/title_labors_background.png")
local release_img = sol.surface.create("menus/title_labors_release.png")
local press_space_img

local frame_1_img = sol.surface.create("menus/title_labors_frame_1.png")
local frame_2_img = sol.surface.create("menus/title_labors_frame_2.png")
local frame_3_img = sol.surface.create("menus/title_labors_frame_3.png")
local frame_4_img = sol.surface.create("menus/title_labors_frame_4.png")
local frame_5_img = sol.surface.create("menus/title_labors_frame_5.png")
local frame_6_img = sol.surface.create("menus/title_labors_frame_6.png")
local frame_7_img = sol.surface.create("menus/title_labors_frame_7.png")
local frame_8_img = sol.surface.create("menus/title_labors_frame_8.png")

local frame_1_img_draw = true
local frame_2_img_draw = true
local frame_3_img_draw = true
local frame_4_img_draw = true
local frame_5_img_draw = true
local frame_6_img_draw = true
local frame_7_img_draw = true
local frame_8_img_draw = true

local function press_space_fading()
  press_space_img:fade_out(40,function()
    press_space_img:fade_in(40,function()
      press_space_fading() 
    end)
  end)
end

function title_screen:on_started()

  press_space_img = sol.surface.create(sol.language.get_language().."/title/title_labors_press_space.png")
  sol.audio.play_music("creations/labors/title_labors")

  release_img:set_opacity(0)
  press_space_img:set_opacity(0)
  frames_img:set_opacity(0)
  zeldo_img:set_opacity(0)
  gamepad_img:set_opacity(0)
  logo_img:set_opacity(0)
  background_slabs_img:set_opacity(0)

  frame_1_img:set_opacity(0)
  frame_2_img:set_opacity(0)
  frame_3_img:set_opacity(0)
  frame_4_img:set_opacity(0)
  frame_5_img:set_opacity(0)
  frame_6_img:set_opacity(0)
  frame_7_img:set_opacity(0)
  frame_8_img:set_opacity(0)

    sol.timer.start(title_screen,11000,function()
        zeldo_img:fade_in(50,function()
          frames_img:fade_in(75) 
          gamepad_img:fade_in(75,function()
            sol.timer.start(title_screen,900,function()
              logo_img:fade_in(25,function()
                is_skipping = true
                release_img:fade_in(75)
                press_space_img:fade_in(100,function()
                  press_space_fading()
                end)
              end)
            end)
          end)
        end)
    end)

    sol.timer.start(title_screen,1000,function()
      frame_1_img:fade_in(75)
      sol.timer.start(title_screen,1000,function()
        frame_2_img:fade_in(50)
        sol.timer.start(title_screen,500,function()
          frame_3_img:fade_in(50)
          sol.timer.start(title_screen,500,function()
            frame_4_img:fade_in(25)
            sol.timer.start(title_screen,250,function()
              frame_5_img:fade_in(50)
              sol.timer.start(title_screen,250,function()
                frame_6_img:fade_in(25)
                sol.timer.start(title_screen,500,function()
                  frame_7_img:fade_in(50)
                  sol.timer.start(title_screen,1000,function()
                    frame_8_img:fade_in(75)
                    sol.timer.start(title_screen,3000,function()
                      frame_1_img:fade_out(75)
                      frame_2_img:fade_out(50)
                      frame_3_img:fade_out(50)
                      frame_4_img:fade_out(25)
                      frame_5_img:fade_out(50)
                      frame_6_img:fade_out(25)
                      frame_7_img:fade_out(50)
                      frame_8_img:fade_out(75,function()
                        background_slabs_img:fade_in(50)
                      end)
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
end

function title_screen:on_draw(dst_surface)

  background_img:draw(dst_surface)
  background_slabs_img:draw(dst_surface)
  frames_img:draw(dst_surface)
	zeldo_img:draw(dst_surface)
  gamepad_img:draw(dst_surface)
	logo_img:draw(dst_surface)
  press_space_img:draw(dst_surface)
	release_img:draw(dst_surface)

	if frame_1_img_draw then frame_1_img:draw(dst_surface) end
	if frame_2_img_draw then frame_2_img:draw(dst_surface) end
	if frame_3_img_draw then frame_3_img:draw(dst_surface) end
	if frame_4_img_draw then frame_4_img:draw(dst_surface) end
	if frame_5_img_draw then frame_5_img:draw(dst_surface) end
	if frame_6_img_draw then frame_6_img:draw(dst_surface) end
	if frame_7_img_draw then frame_7_img:draw(dst_surface) end
	if frame_8_img_draw then frame_8_img:draw(dst_surface) end

end

function title_screen:on_key_pressed(key)
  if is_fading then
    return true
  end
  if is_skipping then
    is_fading = true
    sol.audio.play_sound("save_menu_start_game")
    press_space_img:fade_out(25)
    frames_img:fade_out(25)
    zeldo_img:fade_out(25)
    gamepad_img:fade_out(25)
    background_slabs_img:fade_out(25)
    logo_img:fade_out(25)
    release_img:fade_out(25,function() sol.menu.stop(title_screen) end)
  end
  is_skipping = true

  sol.timer.stop_all(title_screen)

  release_img:set_opacity(255)
  press_space_img:set_opacity(255)
  frames_img:set_opacity(255)
  zeldo_img:set_opacity(255)
  gamepad_img:set_opacity(255)
  logo_img:set_opacity(255)
  background_slabs_img:set_opacity(255)
  frame_1_img_draw = false
  frame_2_img_draw = false
  frame_3_img_draw = false
  frame_4_img_draw = false
  frame_5_img_draw = false
  frame_6_img_draw = false
  frame_7_img_draw = false
  frame_8_img_draw = false
  press_space_fading()

end

function title_screen:on_joypad_button_pressed(button)
  return self:on_key_pressed("space")
end

return title_screen
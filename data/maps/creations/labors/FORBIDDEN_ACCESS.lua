local map = ...
local game = map:get_game()

local console_background = sol.surface.create("entities/Decorations/console.png")
local draw_bg = false

local instruction_1 = sol.surface.create("entities/Decorations/console_instruction_1.png")
local draw_instruction_1 = false
local instruction_1_done = sol.surface.create("entities/Decorations/console_instruction_1_done.png")
local draw_instruction_1_done = false

local instruction_2 = sol.surface.create("entities/Decorations/console_instruction_2.png")
local draw_instruction_2 = false
local instruction_2_done = sol.surface.create("entities/Decorations/console_instruction_2_done.png")
local draw_instruction_2_done = false

local instruction_3 = sol.surface.create("entities/Decorations/console_instruction_3.png")
local draw_instruction_3 = false
local instruction_3_done = sol.surface.create("entities/Decorations/console_instruction_3_done.png")
local draw_instruction_3_done = false

local instruction_4 = sol.surface.create("entities/Decorations/console_instruction_4.png")
local draw_instruction_4 = false
local instruction_4_done = sol.surface.create("entities/Decorations/console_instruction_4_done.png")
local draw_instruction_4_done = false

local instruction_5 = sol.surface.create("entities/Decorations/console_instruction_5.png")
local draw_instruction_5 = false

local get_out_switch = false
local get_out_here = sol.surface.create("screen_image/GETOUT.png")
get_out_here:set_scale(2, 2)


function map:on_started()

  if game:get_value("CH3ATER_forgotten_corridor") then
    print("SALE TRICHEUR ! DISPARAIS !")
    if get_out_switch == false then
      hero:freeze()
      game:set_hud_enabled(false)
      sol.audio.play_sound("raz64/screamer_002")
      get_out_switch = true
      sol.video.set_fullscreen(true)
      sol.video.set_cursor_visible(false)
      sol.timer.start(map, 2000, function()
        sol.video.set_fullscreen(false)
        sol.video.set_cursor_visible(true)
        sol.main.exit()
      end)
    end
    return
  end

  game:set_value("dark_room",true)
  sol.timer.start(map,10,function() game:set_value("dark_room",false) end)

  hero:set_invincible()

  sol.audio.play_sound("raz64/aqua_screamer")
  sol.timer.start(map, 3000, function()
    draw_bg = true
    sol.timer.start(map, 1500, function()
      draw_instruction_1 = true
      sol.timer.start(map, 2000, function()
        draw_instruction_1_done = true
        draw_instruction_1 = false
        sol.audio.play_music("creations/labors/DARK_IMPETUS")
        sol.timer.start(map, 5000, function()
          draw_instruction_2 = true
          draw_instruction_1_done = false
          sol.timer.start(map, 2000, function()
            draw_instruction_2_done = true
            draw_instruction_2 = false
            print("Tu pensais vraiment pouvoir te jouer de moi si facilement ?")
            sol.timer.start(map, 5000, function()
              draw_instruction_3 = true
              draw_instruction_2_done = false
              sol.timer.start(map, 2000, function()
                draw_instruction_3_done = true
                draw_instruction_3 = false
                print("Pars maintenant. Sinon tu le regretteras.")
                sol.timer.start(map, 9000, function()
                  map:set_entities_enabled("CRAZY_",true)
                  local x, y, layer = hero:get_position()
                  CRAZY_1:set_position(x,y,layer - 1)
                  CRAZY_2:set_position(x,y,layer - 1)
                  CRAZY_3:set_position(x,y,layer - 1)
                  CRAZY_4:set_position(x,y,layer - 1)
                  CRAZY_1:get_sprite():set_direction(0)
                  CRAZY_2:get_sprite():set_direction(1)
                  CRAZY_3:get_sprite():set_direction(2)
                  CRAZY_4:get_sprite():set_direction(3)
                  draw_instruction_4 = true
                  draw_instruction_3_done = false
                  sol.timer.start(map, 11000, function()
                    draw_instruction_4_done = true
                    draw_instruction_4 = false
                    print("Tu ne reviendras plus ici. Rentre chez toi, PLAYERNAME")
                    sol.timer.start(map, 10000, function()
                      draw_instruction_5 = true
                      draw_instruction_4_done = false
                      sol.timer.start(map, 2000, function()
                        game:set_value("CH3ATER_forgotten_corridor", true)
                        game:save()
                        sol.main.reset()
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
  end)

end

function game:on_draw(dst_surface)
  if draw_bg then console_background:draw(dst_surface) end

  if draw_instruction_1 then instruction_1:draw(dst_surface) end
  if draw_instruction_1_done then instruction_1_done:draw(dst_surface) end

  if draw_instruction_2 then instruction_2:draw(dst_surface) end
  if draw_instruction_2_done then instruction_2_done:draw(dst_surface) end

  if draw_instruction_3 then instruction_3:draw(dst_surface) end
  if draw_instruction_3_done then instruction_3_done:draw(dst_surface) end

  if draw_instruction_4 then instruction_4:draw(dst_surface) end
  if draw_instruction_4_done then instruction_4_done:draw(dst_surface) end

  if draw_instruction_5 then instruction_5:draw(dst_surface) end

  if get_out_switch == true then
    local var_dd_2 = (( math.ceil(sol.main.get_elapsed_time()/40) )%10)
    get_out_here:draw(dst_surface, -(320*(var_dd_2%5)), -(240*(math.max(math.ceil((var_dd_2-4)/5),0))) )
  end
end
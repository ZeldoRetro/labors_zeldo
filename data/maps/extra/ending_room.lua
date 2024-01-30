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

--REGARDER LES PORTRAITS
local function look_painting(painting_sprite,painting_dialog)
  hero:freeze()
  painting_sprite:set_enabled(true)
  painting_sprite:get_sprite():fade_in(25,function()
    game:set_hud_enabled(false)
    sol.timer.start(map,1500,function()
      game:set_dialog_position("bottom")
      game:set_dialog_style("blank")
      game:start_dialog(painting_dialog,function()
        game:set_dialog_position("auto")
        game:set_hud_enabled(true)
        painting_sprite:get_sprite():fade_out(25,function()
          painting_sprite:set_enabled(false)
          sol.audio.play_sound("spectral_sound")
          hero:teleport("creations/labors/tott/hub","start_razer_room")
          hero:unfreeze()
        end)
      end)
    end)
  end)
end

function painting_razdarac_room_npc:on_interaction()
  look_painting(painting_razdarac_room,"LABORS.tott.paintings.razdarac_room")
end
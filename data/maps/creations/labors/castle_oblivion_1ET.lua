local map = ...
local game = map:get_game()
local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

texte_lieu = sol.text_surface.create{
  text_key = "location.castle_oblivion_1ET",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

--DÉBUT DE LA MAP
function map:on_started()
  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")

  --Intro avec Zeldo faite
  if game:get_value("labors_intro_done") then sensor_intro:set_enabled(false) map:set_entities_enabled("zeldo_intro",false) end
end

--ZELDO AU DÉBUT DE L'ÉTAGE : INTRO
function sensor_intro:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.timer.start(map,1000,function()
    zeldo:get_sprite():set_direction(3)
    sol.timer.start(map,10,function()
      game:start_dialog("LABORS.entrance",function()
        local movement = sol.movement.create("straight")
        movement:set_angle(math.pi / 2)
        movement:set_max_distance(128)
        movement:set_speed(88)
        movement:set_ignore_obstacles()
        movement:start(map:get_entity("zeldo_intro"))
        hero:unfreeze()
        game:set_value("labors_intro_done",true)
      end)
    end)
  end)
end

--ZELDO A LA FIN DE L'ÉTAGE : FIN DE LA 1ERE VAGUE
function sensor_ending:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.timer.start(map,1000,function()
    zeldo:get_sprite():set_direction(3)
    sol.timer.start(map,500,function()
      game:start_dialog("LABORS.end_1st_floor",function()
        zeldo:get_sprite():set_animation("protect")
        sol.audio.play_sound("warp")
        zeldo:get_sprite():fade_out(50,function() 
          zeldo:set_enabled(false) 
          sol.audio.play_music("ending",false)
          hero:teleport("cutscenes/ending_2")
        end)
      end)
    end)
  end)
end
local map = ...
local game = map:get_game()

texte_lieu = sol.text_surface.create{
  text_key = "location.castle_oblivion_RDC",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

--DÉBUT DE LA MAP
function map:on_started()
  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")
end

--Mur invisible pour ne pas sortir
function castle_leave_sensor:on_activated()
  game:start_dialog("LABORS.cant_leave",function()
    hero:freeze()
    hero:set_direction(1)
    hero:set_animation("walking")
    local movement = sol.movement.create("straight")
    movement:set_speed(88)
    movement:set_angle(math.pi / 2)
    movement:set_ignore_obstacles()
    movement:set_max_distance(16)
    movement:start(hero,function()  
      hero:unfreeze()
    end)  
  end)
end
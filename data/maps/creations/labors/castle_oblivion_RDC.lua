local map = ...
local game = map:get_game()

texte_lieu = sol.text_surface.create{
  text_key = "location.castle_oblivion_RDC",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

function map:set_joypad_commands()

  -- Button mapping according commonly used xbox gamepad on PC
  game:set_command_joypad_binding("pause", "button 7")  -- button 7 = Menu/Start (xbox/pc)
  game:set_command_joypad_binding("up", "hat 0 up")
  game:set_command_joypad_binding("left", "hat 0 left")
  game:set_command_joypad_binding("right", "hat 0 right")
  game:set_command_joypad_binding("down", "hat 0 down")
end

--DÉBUT DE LA MAP
function map:on_started()

  --Reset du statut
  game:set_max_life(20*4)
  game:set_life(game:get_max_life())
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  game:get_item("equipment/tunic"):set_variant(1)
  game:set_ability("tunic",1)
  game:get_item("equipment/sword"):set_variant(0)
  game:get_item("equipment/shield"):set_variant(0)

  game:set_value("force",1)
  game:set_value("defense",1)

  game:get_item("inventory/lamp"):set_variant(0)
  game:get_item("inventory/boomerang"):set_variant(0)
  game:get_item("inventory/hookshot"):set_variant(0)
  game:get_item("inventory/hammer"):set_variant(0)
  game:get_item("inventory/fire_rod"):set_variant(0)
  game:get_item("inventory/ice_rod"):set_variant(0)
  game:get_item("inventory/ocarina"):set_variant(0)
  game:get_item("inventory/magic_powder"):set_variant(0)
  game:get_item("inventory/monicle_truth"):set_variant(0)
  game:get_item("equipment/bomb_bag"):set_variant(0)
  game:get_item("equipment/flippers"):set_variant(0)
  game:set_ability("swim",0)
  game:get_item("equipment/glove"):set_variant(0)
  game:set_ability("lift",1)
  local bombs_counter = game:get_item("inventory/bombs_counter")
  bombs_counter:set_variant(0)
  bombs_counter:set_amount(0)
  game:get_item("equipment/quiver"):set_variant(0)
  local arrows_counter = game:get_item("inventory/bow")
  arrows_counter:set_variant(0)
  arrows_counter:set_amount(0)

  --Upgrades si achat au magasin
  if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end

  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")

  map:set_joypad_commands()
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
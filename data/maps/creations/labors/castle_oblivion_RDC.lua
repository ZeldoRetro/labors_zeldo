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
  game:set_command_joypad_binding("action", "button 0")  -- button 0 = A (xbox/pc)
  game:set_command_joypad_binding("attack", "button 2")  -- button 2 = X (xbox/pc)
  game:set_command_joypad_binding("item_1", "button 3")  -- button 3 = Y (xbox/pc)
  game:set_command_joypad_binding("item_2", "button 1")  -- button 1 = B (xbox/pc)
  game:set_command_joypad_binding("pause", "button 7")   -- button 7 = Menu/Start (xbox/pc)
  game:set_command_joypad_binding("up", "hat 0 up")
  game:set_command_joypad_binding("left", "hat 0 left")
  game:set_command_joypad_binding("right", "hat 0 right")
  game:set_command_joypad_binding("down", "hat 0 down")
end

--DÉBUT DE LA MAP
function map:on_started(destination)

  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")
  hero:set_sword_sprite_id("npc/playing_character/eldran_sword1")
  hero:set_shield_sprite_id("npc/playing_character/eldran_shield1")

  --Reset du statut
  game:set_max_life(20*4)
  game:set_life(game:get_max_life())
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  game:get_item("equipment/tunic"):set_variant(1)
  game:set_ability("tunic",1)
  if game:get_value("zeldo_wave_1_defeated") then
    game:get_item("equipment/sword"):set_variant(6)
  else game:get_item("equipment/sword"):set_variant(0) end
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

  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")
  hero:set_sword_sprite_id("npc/playing_character/eldran_sword1")

  -- RESET DES UPGRADES : CHANGEMENT DE VAGUE
  game:get_item("upgrade_cards/tott_arrows"):set_variant(0)
  game:get_item("upgrade_cards/tott_attack"):set_variant(0)
  game:get_item("upgrade_cards/tott_magic"):set_variant(0)
  game:get_item("upgrade_cards/tott_bombs"):set_variant(0)
  game:get_item("upgrade_cards/tott_defence"):set_variant(0)
  game:get_item("upgrade_cards/tott_casual"):set_variant(0)

  game:set_value("force",1)
  game:set_value("defense",1)

  if destination == entree then map:set_joypad_commands() end
end

function map:on_opening_transition_finished(destination)
  if destination == entree then game:set_dialog_style("blank") game:start_dialog("LABORS.1st_message") end
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
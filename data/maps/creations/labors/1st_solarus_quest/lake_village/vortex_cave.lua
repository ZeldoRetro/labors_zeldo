local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
    -- Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    if game:get_value("get_shield_10016") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2")
    else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end

  -- Énigme de torches: chacune a une durée différente
  auto_timed_torch_auto_door_4_1:set_duration(2000)
  auto_timed_torch_auto_door_4_2:set_duration(500)
  auto_timed_torch_auto_door_4_3:set_duration(5000)
  auto_timed_torch_auto_door_4_4:set_duration(3500)
end)
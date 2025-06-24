local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
  if game:get_value("get_shield_10016") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2")
  else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end
end)

-- BOSS VISIBLE SI TOUTES LES LAMPES SONT ALLUMEES
local lit_torch = 0
for torch in map:get_entities("timed_torch_") do
  function torch:on_lit() 
    lit_torch = lit_torch + 1
    sol.timer.start(10000,function() 
      lit_torch = lit_torch - 1
    end)
  end
end
function map:on_update()
  if not game:get_value("miniboss_10016") then
    if lit_torch == 0 then
      auto_enemy_auto_door_1_1:set_invincible()
      auto_enemy_auto_door_1_1:set_visible(false)
      auto_enemy_auto_door_1_1:set_can_attack(false)
    else
      auto_enemy_auto_door_1_1:set_visible(true)
      auto_enemy_auto_door_1_1:set_attack_consequence("sword",1)
      auto_enemy_auto_door_1_1:set_fire_reaction(2)
      auto_enemy_auto_door_1_1:set_can_attack(true)
    end
  end
end
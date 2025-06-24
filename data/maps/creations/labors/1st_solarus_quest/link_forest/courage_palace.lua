local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:set_sword_sprite_id("hero/sword1")
  hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")
end)

-- ÉNIGME DE BLOCS 1 (CLÉ)
local goal = 0

for switch in map:get_entities("block_puzzle_1_switch_") do
  function switch:on_activated()
    goal = goal + 1
    if goal == 2 then
      sol.timer.start(map, 100, function()
        auto_switch_auto_chest_key_1:on_activated()
        map:set_entities_enabled("block_puzzle_1_block_",false)
        map:set_entities_enabled("definitive_block_puzzle_1_block_",true)
      end)
    end
  end
  function switch:on_inactivated() goal = goal - 1 end
end
local map = ...
local game = map:get_game()

keychest:register_event("on_opened",function()
  map:set_entities_enabled("keychest_lava_pit_",true)
  hero:start_treasure("dungeons/small_key",1,"key_10014_8_pick")
end)

map:register_event("on_started",function()
  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:set_sword_sprite_id("hero/sword1")
  hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")
end)
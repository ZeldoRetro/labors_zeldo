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
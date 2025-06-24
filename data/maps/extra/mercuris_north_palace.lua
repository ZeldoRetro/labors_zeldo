local create_layer_music = require("scripts/data/layer_music")

local map = ...
local game = map:get_game()
local music = create_layer_music(map, "north_palace")

--Modèle LINK
local hero = map:get_hero()
hero:set_tunic_sprite_id("hero/tunic1")
hero:set_sword_sprite_id("hero/sword3")
hero:set_shield_sprite_id("hero/shield2")

game:set_max_life(12*4)
game:set_life(game:get_max_life())
game:set_item_assigned(1, nil)
game:set_item_assigned(2, nil)
game:get_item("equipment/tunic"):set_variant(1)
game:get_item("equipment/sword"):set_variant(3)
game:get_item("equipment/shield"):set_variant(2)

game:set_value("force",3)
game:set_value("defense",2)

--Upgrades si achat au magasin
if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end

function map:on_started()
  music:play()
  music:set_stage("main")
end

function music_stage_main:on_activated()
  music:set_stage("main")
end

function music_stage_main_2:on_activated()
  music:set_stage("main")
end

function music_stage_moon:on_activated()
  music:set_stage("moon")
end

function music_stage_stone:on_activated()
  music:set_stage("stone")
end
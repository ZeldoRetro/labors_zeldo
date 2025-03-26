local map = ...
local game = map:get_game()
local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DÉBUT DE LA MAP
function map:on_started()

  shrine_portal:set_drawn_in_y_order(true)

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

  --Zeldo passé
  if game:get_value("labors_rules_done") then sensor_rules:set_enabled(false) zeldo:set_enabled(false) end

  --Téléporteur ouverts après X trophées
  if game:get_item("quest_items/trophy_labors_tott"):get_amount() >= 1 then
    map:set_entities_enabled("lock_1_trophy_",false)
    tp_water_temple:set_enabled(true)
    tp_hylia_waterfall:set_enabled(true)
    if game:get_item("quest_items/trophy_labors_tott"):get_amount() >= 3 then
      map:set_entities_enabled("lock_3_trophy_",false)
      tp_ice_cave:set_enabled(true)
      tp_ancient_catacomb:set_enabled(true)
      if game:get_item("quest_items/trophy_labors_tott"):get_amount() >= 6 then
        map:set_entities_enabled("lock_6_trophy_",false)
        tp_castle_tower:set_enabled(true)
      end
    end
  end

  --Coffre final et Clé du Spoil apparait quand fini Boss final
  if game:get_value("labors_tott_wave_1_1_done") then map:set_entities_enabled("final_chest_1_",true) map:set_entities_enabled("yellow_key",true) end

  --Articles du Magasin
  if not game:get_value("labors_magic_flask_upgrade_wave_1") then
    if game:get_value("labors_casualization_wave_1") then shop_magic_flask_upgrade:set_enabled(true) elseif game:get_value("labors_bottle_1") then shop_bottle_2:set_enabled(true) end
  end
  if not game:get_value("labors_attack_boost_wave_1") then
    if game:get_value("labors_quiver_wave_1") then shop_attack_boost:set_enabled(true) end
  end
  if not game:get_value("labors_defense_boost_wave_1") then
    if game:get_value("labors_bomb_bag_wave_1") then shop_defense_boost:set_enabled(true) end
  end

  --Clés du Magasin
  if game:get_value("red_key_10000_1_1") then map:set_entities_enabled("red_key",false) end
  if game:get_value("blue_key_10000_1_1") then map:set_entities_enabled("blue_key",false) end
  if game:get_value("green_key_10000_1_1") then map:set_entities_enabled("green_key",false) end
  if game:get_value("yellow_key_10000_1") then map:set_entities_enabled("yellow_key",false) end

  --Marchands
  if game:get_value("red_key_10000_1_1") and game:get_value("blue_key_10000_1_1") and game:get_value("green_key_10000_1_1") and game:get_value("yellow_key_10000_1") then map:set_entities_enabled("welcome_shop_remembrance",false) end
  if game:get_value("labors_magic_flask_upgrade_wave_1") and game:get_value("labors_attack_boost_wave_1") and game:get_value("labors_defense_boost_wave_1") then welcome_shop:set_enabled(false) welcome_shop_npc:set_enabled(false) end
end

--ZELDO EXPLIQUE LES RÈGLES
function sensor_rules:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.timer.start(map,500,function()
    zeldo:get_sprite():set_direction(3)
    sol.timer.start(map,10,function()
      game:start_dialog("LABORS.rules",function()
        zeldo:get_sprite():set_animation("protect")
        sol.audio.play_sound("warp")
        zeldo:get_sprite():fade_out(50,function() 
          zeldo:set_enabled(false)
          game:set_value("labors_rules_done",true)
          hero:unfreeze()
        end)
      end)
    end)
  end)
end

--DIALOGUES AVEC MARCHANDS
function welcome_shop:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors")
end
function welcome_shop_potion:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors_potion")
end
function welcome_shop_remembrance:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors_remembrance")
end

--ITEMS ACHETÉS S'ACTUALISENT EN DIRECT POUR LE SUIVANT
if shop_bottle_1 ~= nil then 
  function shop_bottle_1:on_bought()
    shop_bottle_2:set_enabled(true)
  end
end
if shop_bottle_2 ~= nil then 
  function shop_bottle_2:on_bought()
    shop_magic_flask_upgrade:set_enabled(true)
  end
end
if shop_quiver ~= nil then 
  function shop_quiver:on_bought()
    shop_attack_boost:set_enabled(true)
  end
end
if shop_bomb_bag ~= nil then 
  function shop_bomb_bag:on_bought()
    shop_defense_boost:set_enabled(true)
  end
end


--PAS DE POTION SI PAS DE BOUTEILLE VIDE
if game:get_value("labors_bottle_1_wave_1") then
  function shop_potion_1:on_buying()
    local first_empty_bottle = self:get_game():get_first_empty_bottle()
    if first_empty_bottle == nil then
      sol.audio.play_sound("wrong")
      game:start_dialog("_shop.no_empty_bottle")
    else return true end
  end
  function shop_potion_2:on_buying()
    local first_empty_bottle = self:get_game():get_first_empty_bottle()
    if first_empty_bottle == nil then
      sol.audio.play_sound("wrong")
      game:start_dialog("_shop.no_empty_bottle")
    else return true end
  end
  function shop_potion_3:on_buying()
    local first_empty_bottle = self:get_game():get_first_empty_bottle()
    if first_empty_bottle == nil then
      sol.audio.play_sound("wrong")
      game:start_dialog("_shop.no_empty_bottle")
    else return true end
  end
end

--ARTICLES DU MAGASIN DE SOUVENIR
--CLÉ ROUGE
function red_key:on_interaction()
  game:start_dialog("shop.souvenir.red_key",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard"):get_amount() >= 20 then
        game:get_item("quest_items/remembrance_shard"):remove_amount(20)
        map:set_entities_enabled("red_key",false)
        hero:start_treasure("dungeons/red_key",1,"red_key_10000_1_1")
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end
function blue_key:on_interaction()
  game:start_dialog("shop.souvenir.blue_key",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard"):get_amount() >= 30 then
        game:get_item("quest_items/remembrance_shard"):remove_amount(30)
        map:set_entities_enabled("blue_key",false)
        hero:start_treasure("dungeons/blue_key",1,"blue_key_10000_1_1")
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end
function green_key:on_interaction()
  game:start_dialog("shop.souvenir.green_key",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard"):get_amount() >= 40 then
        game:get_item("quest_items/remembrance_shard"):remove_amount(40)
        map:set_entities_enabled("green_key",false)
        hero:start_treasure("dungeons/green_key",1,"green_key_10000_1_1")
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end
function yellow_key:on_interaction()
  game:start_dialog("shop.souvenir.yellow_key",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard"):get_amount() >= 10 then
        game:get_item("quest_items/remembrance_shard"):remove_amount(10)
        map:set_entities_enabled("yellow_key",false)
        hero:start_treasure("dungeons/yellow_key",1,"yellow_key_10000_1")
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end

--REGARDER LES PORTRAITS : ZONES ET TABLEAUX DE DEV

local function look_frame(frame_dialog, test_image)
  game:start_dialog(frame_dialog,function()
    game:set_pause_allowed(false)
    test_image:fade_in(30,function()
      game:start_dialog("empty", function()
        test_image:fade_out(50, function()
          game:set_pause_allowed(true)
          hero:unfreeze()
          function sol.video:on_draw(screen) end
        end)
      end)
    end)
    function sol.video:on_draw(screen)
      local x_size_1, y_size_1 = sol.video.get_window_size()
      local x_size_2, y_size_2 = test_image:get_size()
      local calcul = 1
      if x_size_1 < y_size_1 then
        calcul = x_size_1/x_size_2
      else
        calcul = y_size_1/y_size_2
      end
      test_image:set_scale(calcul, calcul)
      test_image:draw(screen, 0, 0)
    end
  end)
end

for npc in map:get_entities("npc_frame_") do
  function npc:on_interaction()
    hero:freeze()
    look_frame(npc:get_property("dialog"),sol.surface.create(npc:get_property("image")))
  end
end

function map:on_finished()
  function sol.video:on_draw(screen) end
end

--TEST SON ET LISTE DES MUSIQUES
function npc_play_music_1:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.1",function(answer)
    if answer == 1 then switch_play_music_1:on_activated() end
  end)
end
function switch_play_music_1:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_1:set_activated(true)
  sol.audio.play_music("creations/labors/tott/light_temple")
end

function npc_play_music_2:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.2",function(answer)
    if answer == 1 then switch_play_music_2:on_activated() end
  end)
end
function switch_play_music_2:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_2:set_activated(true)
  sol.audio.play_music("creations/labors/tott/earth_temple")
end

function npc_play_music_3:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.3",function(answer)
    if answer == 1 then switch_play_music_3:on_activated() end
  end)
end
function switch_play_music_3:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_3:set_activated(true)
  sol.audio.play_music("creations/labors/tott/fire_temple")
end

function npc_play_music_4:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.4",function(answer)
    if answer == 1 then switch_play_music_4:on_activated() end
  end)
end
function switch_play_music_4:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_4:set_activated(true)
  sol.audio.play_music("creations/labors/tott/water_temple")
end

function npc_play_music_5:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.5",function(answer)
    if answer == 1 then switch_play_music_5:on_activated() end
  end)
end
function switch_play_music_5:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_5:set_activated(true)
  sol.audio.play_music("creations/labors/tott/desert_temple")
end

function npc_play_music_6:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.6",function(answer)
    if answer == 1 then switch_play_music_6:on_activated() end
  end)
end
function switch_play_music_6:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_6:set_activated(true)
  sol.audio.play_music("creations/labors/tott/ice_temple")
end

function npc_play_music_7:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.7",function(answer)
    if answer == 1 then switch_play_music_7:on_activated() end
  end)
end
function switch_play_music_7:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_7:set_activated(true)
  sol.audio.play_music("creations/labors/tott/wind_temple")
end

function npc_play_music_8:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.8",function(answer)
    if answer == 1 then switch_play_music_8:on_activated() end
  end)
end
function switch_play_music_8:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_8:set_activated(true)
  sol.audio.play_music("creations/labors/tott/shadow_temple")
end

function npc_play_music_9:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.9",function(answer)
    if answer == 1 then switch_play_music_9:on_activated() end
  end)
end
function switch_play_music_9:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_9:set_activated(true)
  sol.audio.play_music("creations/labors/tott/tott")
end

function npc_play_music_10:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.10",function(answer)
    if answer == 1 then switch_play_music_10:on_activated() end
  end)
end
function switch_play_music_10:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_10:set_activated(true)
  sol.audio.play_music("creations/labors/tott/wind_ruins")
end

function npc_play_music_11:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.11",function(answer)
    if answer == 1 then switch_play_music_11:on_activated() end
  end)
end
function switch_play_music_11:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_11:set_activated(true)
  sol.audio.play_music("creations/labors/tott/ancient_catacomb")
end

function npc_play_music_12:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.12",function(answer)
    if answer == 1 then switch_play_music_12:on_activated() end
  end)
end
function switch_play_music_12:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_12:set_activated(true)
  sol.audio.play_music("creations/labors/tott/hyrule_castle_ruins")
end

function npc_play_music_13:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.13",function(answer)
    if answer == 1 then switch_play_music_13:on_activated() end
  end)
end
function switch_play_music_13:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_13:set_activated(true)
  sol.audio.play_music("creations/labors/tott/casino")
end

function npc_play_music_14:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.14",function(answer)
    if answer == 1 then switch_play_music_14:on_activated() end
  end)
end
function switch_play_music_14:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_14:set_activated(true)
  sol.audio.play_music("creations/labors/tott/hyrule_field_intro")
end

function npc_play_music_15:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.15",function(answer)
    if answer == 1 then switch_play_music_15:on_activated() end
  end)
end
function switch_play_music_15:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_15:set_activated(true)
  sol.audio.play_music("creations/labors/tott/field")
end

function npc_play_music_16:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.16",function(answer)
    if answer == 1 then switch_play_music_16:on_activated() end
  end)
end
function switch_play_music_16:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_16:set_activated(true)
  sol.audio.play_music("creations/labors/tott/field_night")
end

function npc_play_music_17:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.17",function(answer)
    if answer == 1 then switch_play_music_17:on_activated() end
  end)
end
function switch_play_music_17:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_17:set_activated(true)
  sol.audio.play_music("creations/labors/tott/castle_town")
end

function npc_play_music_18:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.18",function(answer)
    if answer == 1 then switch_play_music_18:on_activated() end
  end)
end
function switch_play_music_18:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_18:set_activated(true)
  sol.audio.play_music("creations/labors/tott/island_village")
end

function npc_play_music_19:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.19",function(answer)
    if answer == 1 then switch_play_music_19:on_activated() end
  end)
end
function switch_play_music_19:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_19:set_activated(true)
  sol.audio.play_music("creations/labors/tott/forest")
end

function npc_play_music_20:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.20",function(answer)
    if answer == 1 then switch_play_music_20:on_activated() end
  end)
end
function switch_play_music_20:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_20:set_activated(true)
  sol.audio.play_music("creations/labors/tott/icy_peak")
end

function npc_play_music_21:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.21",function(answer)
    if answer == 1 then switch_play_music_21:on_activated() end
  end)
end
function switch_play_music_21:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_21:set_activated(true)
  sol.audio.play_music("creations/labors/tott/tabanta_swamp")
end

function npc_play_music_22:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.22",function(answer)
    if answer == 1 then switch_play_music_22:on_activated() end
  end)
end
function switch_play_music_22:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_22:set_activated(true)
  sol.audio.play_music("creations/labors/tott/sacred_place")
end

function npc_play_music_23:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.23",function(answer)
    if answer == 1 then switch_play_music_23:on_activated() end
  end)
end
function switch_play_music_23:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_23:set_activated(true)
  sol.audio.play_music("creations/labors/tott/hyrule_castle_new")
end

function npc_play_music_24:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.24",function(answer)
    if answer == 1 then switch_play_music_24:on_activated() end
  end)
end
function switch_play_music_24:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_24:set_activated(true)
  sol.audio.play_music("creations/labors/tott/house")
end

function npc_play_music_25:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.25",function(answer)
    if answer == 1 then switch_play_music_25:on_activated() end
  end)
end
function switch_play_music_25:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_25:set_activated(true)
  sol.audio.play_music("creations/labors/tott/inside_ship")
end

function npc_play_music_26:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.26",function(answer)
    if answer == 1 then switch_play_music_26:on_activated() end
  end)
end
function switch_play_music_26:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_26:set_activated(true)
  sol.audio.play_music("cave")
end

function npc_play_music_27:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.27",function(answer)
    if answer == 1 then switch_play_music_27:on_activated() end
  end)
end
function switch_play_music_27:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_27:set_activated(true)
  sol.audio.play_music("creations/forgotten_legend/people_in_trouble")
end

function npc_play_music_28:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.28",function(answer)
    if answer == 1 then switch_play_music_28:on_activated() end
  end)
end
function switch_play_music_28:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_28:set_activated(true)
  sol.audio.play_music("creations/forgotten_legend/agahnim_battle_1")
end

function npc_play_music_29:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.29",function(answer)
    if answer == 1 then switch_play_music_29:on_activated() end
  end)
end
function switch_play_music_29:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_29:set_activated(true)
  sol.audio.play_music("creations/labors/tott/agahnim_battle_2")
end

function npc_play_music_30:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("LABORS.tott.musics.30",function(answer)
    if answer == 1 then switch_play_music_30:on_activated() end
  end)
end
function switch_play_music_30:on_activated()
  for switches in map:get_entities("switch_play_music") do switches:set_activated(false) end
  switch_play_music_30:set_activated(true)
  sol.audio.play_music("creations/labors/tott/agahnim_theme")
end
local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- RESET STATUT

  --Modèle PLAYER
  hero:set_tunic_sprite_id("npc/playing_character/eldran2")
  hero:set_sword_sprite_id("npc/playing_character/eldran_sword1")
  hero:set_shield_sprite_id("npc/playing_character/eldran_shield1")

  -- Stats force/défense + apparence
  game:set_max_life(20*4)
  game:set_life(game:get_max_life())
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  game:get_item("equipment/tunic"):set_variant(1)
  game:set_ability("tunic",1)
  game:get_item("equipment/sword"):set_variant(6)
  game:set_ability("shield",0)
  game:get_item("equipment/shield"):set_variant(0)
  game:set_value("force",1)
  game:set_value("defense",1)

  -- Objets
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
  game:get_item("inventory/bow_light"):set_variant(0)
  game:get_item("inventory/echange_1st_solarus_quest"):set_variant(0)

  -- Objets PLAYER
  if game:get_value("zeldo_wave_1_defeated") then game:get_item("equipment/sword_PLAYER"):set_variant(1) end
  if game:get_value("zeldo_wave_2_defeated") then game:get_item("inventory/bow_PLAYER"):set_variant(1) end

  -- Variables diverses
  game:set_value("dungeon_10017_initialized", false)

  --Upgrades si achat au magasin
  if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
  if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end

  -- Clé verte quand on a la clé rouge
  if game:get_value("red_key_10010_1") then
    map:set_entities_enabled("green_key",true)
  end

  -- Clé jaune quand on a tous les trophées
  if game:get_item("quest_items/trophy_labors_1st_solarus_quest"):get_amount() >= 8 and game:get_value("blue_key_10010_1") then
    map:set_entities_enabled("yellow_key",true)
  end

  -- Coffre final et Clé du Spoil apparait quand fini Boss final
  if game:get_value("labors_wave_2_1_done") then map:set_entities_enabled("final_chest_1_",true) end

  -- Clé Violette apparait quand fini Final Alternatif
  if game:get_value("labors_wave_2_2_done") then map:set_entities_enabled("final_chest_2_",true) end

  -- Articles du Magasin
  if not game:get_value("labors_magic_flask_upgrade_wave_2") then
    if game:get_value("labors_casualization_wave_2") then shop_magic_flask_upgrade:set_enabled(true) end
  end
  if not game:get_value("labors_attack_boost_wave_2") then
    if game:get_value("labors_quiver_wave_2") then shop_attack_boost:set_enabled(true) end
  end
  if not game:get_value("labors_defense_boost_wave_2") then
    if game:get_value("labors_bomb_bag_wave_2") then shop_defense_boost:set_enabled(true) end
  end

  -- Objets permanents du Magasin
  if game:get_value("get_trophy_10012") then map:set_entities_enabled("shop_perma_flippers",true) end
  if game:get_value("get_trophy_10015") then map:set_entities_enabled("shop_perma_bombs",true) end
  if game:get_value("get_trophy_10014") then map:set_entities_enabled("shop_perma_glove_3",true) end
  if game:get_value("get_trophy_10017") and game:get_value("labors_perma_flippers_wave_2") then map:set_entities_enabled("shop_perma_lamp",true) end
  if game:get_value("get_trophy_10016") and game:get_value("labors_perma_bombs_wave_2") and game:get_value("get_boomerang_10016") then map:set_entities_enabled("shop_perma_boomerang_2",true) end
  if game:get_value("get_trophy_10018") and game:get_value("labors_perma_glove_3_wave_2") then map:set_entities_enabled("shop_perma_monicle_truth",true) end

  -- Clés du Magasin
  if game:get_value("red_key_10010_1") then map:set_entities_enabled("red_key",false) end
  if game:get_value("blue_key_10010_1") then map:set_entities_enabled("blue_key",false) end
  if game:get_value("green_key_10010_1") then map:set_entities_enabled("green_key",false) end
  if game:get_value("yellow_key_10010_1") then map:set_entities_enabled("yellow_key",false) end

  -- Marchands
  if game:get_value("red_key_10010_1") and game:get_value("blue_key_10010_1") and game:get_value("green_key_10010_1") and game:get_value("yellow_key_10010_1") then map:set_entities_enabled("welcome_shop_remembrance",false) end
  if game:get_value("labors_magic_flask_upgrade_wave_2") and game:get_value("labors_attack_boost_wave_2") and game:get_value("labors_defense_boost_wave_2") then welcome_shop:set_enabled(false) welcome_shop_npc:set_enabled(false) end
  if game:get_value("labors_perma_lamp_wave_2") and game:get_value("labors_perma_monicle_truth_wave_2") and game:get_value("labors_perma_boomerang_2_wave_2") then welcome_shop_permanent:set_enabled(false) welcome_shop_permanent_npc:set_enabled(false) end

  -- Énigme ordre de switches résolue
  if game:get_value("door_10010_4") then
    tiles_puzzle_switch_1:set_activated(true)
    tiles_puzzle_switch_2:set_activated(true)
    tiles_puzzle_switch_3:set_activated(true)
    tiles_puzzle_switch_4:set_activated(true)
    tiles_puzzle_switch_1:set_locked(true)
    tiles_puzzle_switch_2:set_locked(true)
    tiles_puzzle_switch_3:set_locked(true)
    tiles_puzzle_switch_4:set_locked(true)
  end

end)

-- ZELDO BIENVENUE
function sensor_rules:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.timer.start(map,500,function()
    zeldo:get_sprite():set_direction(3)
    sol.timer.start(map,10,function()
      game:start_dialog("LABORS.zeldo_wave_2.welcome",function()
        hero:start_treasure("inventory/magic_mirror",1,"labors_magic_mirror",function()
          game:start_dialog("LABORS.zeldo_wave_2.welcome_2",function()
            local sprite = zeldo:get_sprite()
            local i = 0
            sol.audio.play_sound("laser")
            sol.timer.start(map, 20, function()
              i = i + 5
              sprite:set_scale(1 - (i / 100), 1 + (i / 100))
              if i < 100 then return true
              else
                zeldo:set_enabled(false)
                game:set_value("labors_wave_2_welcome",true)
                hero:unfreeze()
              end
            end)
          end)
        end)
      end)
    end)
  end)
end

-- DIALOGUES AVEC MARCHANDS
function welcome_shop:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors")
end
function welcome_shop_permanent:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors_permanent")
end
function welcome_shop_remembrance:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_labors_remembrance")
end

-- ITEMS ACHETÉS S'ACTUALISENT EN DIRECT POUR LE SUIVANT

-- CARTES D'UPGRADE
if shop_casual ~= nil then 
  function shop_casual:on_bought()
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

-- OBJETS PERMANENTS DE VAGUE
if shop_perma_bombs ~= nil then 
  function shop_perma_bombs:on_bought()
    if game:get_value("get_trophy_10016") and game:get_value("labors_perma_bombs_wave_2") and game:get_value("get_boomerang_10016") then
      shop_perma_boomerang_2:set_enabled(true)
    end
  end
end
if shop_perma_glove_3 ~= nil then 
  function shop_perma_glove_3:on_bought()
    if game:get_value("get_trophy_10018") and game:get_value("labors_perma_glove_3_wave_2") then
      shop_perma_monicle_truth:set_enabled(true)
    end
  end
end
if shop_perma_flippers ~= nil then 
  function shop_perma_flippers:on_bought()
    if game:get_value("get_trophy_10017") and game:get_value("labors_perma_flippers_wave_2") then
      shop_perma_lamp:set_enabled(true)
    end
  end
end

--ARTICLES DU MAGASIN DE SOUVENIR
--CLÉ ROUGE
function red_key:on_interaction()
  game:start_dialog("shop.souvenir.red_key_2",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):get_amount() >= 30 then
        game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):remove_amount(30)
        map:set_entities_enabled("red_key",false)
        hero:start_treasure("dungeons/red_key",1,"red_key_10010_1",function()
          map:set_entities_enabled("green_key",true)
        end)
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
      if game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):get_amount() >= 40 then
        game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):remove_amount(40)
        map:set_entities_enabled("green_key",false)
        hero:start_treasure("dungeons/green_key",1,"green_key_10010_1")
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
      if game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):get_amount() >= 30 then
        game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):remove_amount(30)
        map:set_entities_enabled("blue_key",false)
        hero:start_treasure("dungeons/blue_key",1,"blue_key_10010_1",function()
          if game:get_item("quest_items/trophy_labors_1st_solarus_quest"):get_amount() >= 8 then map:set_entities_enabled("yellow_key",true) end
        end)
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end
function yellow_key:on_interaction()
  game:start_dialog("shop.souvenir.yellow_key_2",function(answer)
    if answer == 1 then
      if game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):get_amount() >= 50 then
        game:get_item("quest_items/remembrance_shard_1st_solarus_quest"):remove_amount(50)
        map:set_entities_enabled("yellow_key",false)
        hero:start_treasure("dungeons/yellow_key",1,"yellow_key_10010_1")
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("shop.souvenir.not_enough_shards")
      end
    end
  end)
end

-- LIVRE DE LA LISTE DES ÉCLATS DE SOUVENIR
function book_shards_list:on_interaction()
  -- Compte des éclats : Zone 1
  local current_shards = 0
  game:set_dialog_style("book")
  if game:get_value("remembrance_shard_10011_1") then current_shards = current_shards + 5 end
  if game:get_value("remembrance_shard_10011_2") then current_shards = current_shards + 5 end
  if game:get_value("remembrance_shard_10011_3") then current_shards = current_shards + 1 end
  if game:get_value("remembrance_shard_10011_4") then current_shards = current_shards + 1 end
  if game:get_value("remembrance_shard_10011_5") then current_shards = current_shards + 1 end
  if game:get_value("remembrance_shard_10011_6") then current_shards = current_shards + 1 end
  if game:get_value("remembrance_shard_10011_7") then current_shards = current_shards + 1 end
  if game:get_value("heart_container_10011") then current_shards = current_shards + 10 end
  game:start_dialog("book.tips_shards_1st_solarus_quest_list_1", current_shards, function()
    -- Compte des éclats : Zone 2
    local current_shards = 0
    game:set_dialog_style("book")
    if game:get_value("remembrance_shard_10012_1") then current_shards = current_shards + 5 end
    if game:get_value("remembrance_shard_10012_2") then current_shards = current_shards + 1 end
    if game:get_value("remembrance_shard_10012_3") then current_shards = current_shards + 1 end
    if game:get_value("remembrance_shard_10012_4") then current_shards = current_shards + 1 end
    if game:get_value("remembrance_shard_10012_5") then current_shards = current_shards + 1 end
    if game:get_value("remembrance_shard_10012_6") then current_shards = current_shards + 1 end
    game:start_dialog("book.tips_shards_1st_solarus_quest_list_2", current_shards, function()
      -- Compte des éclats : Zone 3
      local current_shards = 0
      game:set_dialog_style("book")
      if game:get_value("remembrance_shard_10013_1") then current_shards = current_shards + 5 end
      if game:get_value("remembrance_shard_10013_2") then current_shards = current_shards + 1 end
      if game:get_value("remembrance_shard_10013_3") then current_shards = current_shards + 1 end
      if game:get_value("remembrance_shard_10013_4") then current_shards = current_shards + 1 end
      if game:get_value("remembrance_shard_10013_5") then current_shards = current_shards + 1 end
      if game:get_value("remembrance_shard_10013_6") then current_shards = current_shards + 1 end
      game:start_dialog("book.tips_shards_1st_solarus_quest_list_3", current_shards, function()
        -- Compte des éclats : Zone 4
        local current_shards = 0
        game:set_dialog_style("book")
        if game:get_value("remembrance_shard_10014_1") then current_shards = current_shards + 5 end
        if game:get_value("remembrance_shard_10014_2") then current_shards = current_shards + 1 end
        if game:get_value("remembrance_shard_10014_3") then current_shards = current_shards + 1 end
        if game:get_value("remembrance_shard_10014_4") then current_shards = current_shards + 1 end
        if game:get_value("remembrance_shard_10014_5") then current_shards = current_shards + 1 end
        if game:get_value("remembrance_shard_10014_6") then current_shards = current_shards + 1 end
        if game:get_value("heart_container_10014") then current_shards = current_shards + 10 end
        game:start_dialog("book.tips_shards_1st_solarus_quest_list_4", current_shards, function()
          -- Compte des éclats : Zone 5
          local current_shards = 0
          game:set_dialog_style("book")
          if game:get_value("remembrance_shard_10015_1") then current_shards = current_shards + 5 end
          if game:get_value("remembrance_shard_10015_2") then current_shards = current_shards + 5 end
          if game:get_value("remembrance_shard_10015_3") then current_shards = current_shards + 1 end
          if game:get_value("remembrance_shard_10015_4") then current_shards = current_shards + 1 end
          if game:get_value("remembrance_shard_10015_5") then current_shards = current_shards + 1 end
          if game:get_value("heart_container_10015") then current_shards = current_shards + 10 end
          game:start_dialog("book.tips_shards_1st_solarus_quest_list_5", current_shards, function()
            -- Compte des éclats : Zone 6
            local current_shards = 0
            game:set_dialog_style("book")
            if game:get_value("remembrance_shard_10016_1") then current_shards = current_shards + 5 end
            if game:get_value("remembrance_shard_10016_2") then current_shards = current_shards + 5 end
            if game:get_value("remembrance_shard_10016_3") then current_shards = current_shards + 5 end
            if game:get_value("remembrance_shard_10016_4") then current_shards = current_shards + 1 end
            if game:get_value("remembrance_shard_10016_5") then current_shards = current_shards + 1 end
            if game:get_value("remembrance_shard_10016_6") then current_shards = current_shards + 1 end
            if game:get_value("remembrance_shard_10016_7") then current_shards = current_shards + 1 end
            if game:get_value("remembrance_shard_10016_8") then current_shards = current_shards + 1 end
            game:start_dialog("book.tips_shards_1st_solarus_quest_list_6", current_shards, function()
              -- Compte des éclats : Zone 7
              local current_shards = 0
              game:set_dialog_style("book")
              if game:get_value("remembrance_shard_10018_2") then current_shards = current_shards + 5 end
              if game:get_value("remembrance_shard_10017_1") then current_shards = current_shards + 5 end
              if game:get_value("remembrance_shard_10017_2") then current_shards = current_shards + 1 end
              if game:get_value("remembrance_shard_10017_3") then current_shards = current_shards + 1 end
              game:start_dialog("book.tips_shards_1st_solarus_quest_list_7", current_shards, function()
                -- Compte des éclats : Zone 8
                local current_shards = 0
                game:set_dialog_style("book")
                if game:get_value("remembrance_shard_10019_1") then current_shards = current_shards + 1 end
                if game:get_value("remembrance_shard_10019_2") then current_shards = current_shards + 1 end
                if game:get_value("remembrance_shard_10019_3") then current_shards = current_shards + 1 end
                if game:get_value("remembrance_shard_10019_4") then current_shards = current_shards + 1 end
                if game:get_value("remembrance_shard_10019_5") then current_shards = current_shards + 1 end
                game:start_dialog("book.tips_shards_1st_solarus_quest_list_8", current_shards, function()
                  -- Compte des éclats : Zone 9
                  local current_shards = 0
                  game:set_dialog_style("book")
                  if game:get_value("remembrance_shard_10018_1") then current_shards = current_shards + 25 end
                  game:start_dialog("book.tips_shards_1st_solarus_quest_list_9", current_shards)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
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

-- INIT DRAW CADRES + ENLEVER OBJETS PLAYER QUAND VERS ZONE DE TRAVAUX
map:register_event("on_finished",function(map)
  function sol.video:on_draw(screen) end

  local hero_x, hero_y = map:get_hero():get_position()
  if hero_x < 776 or hero_y > 720 or hero_x > 824 then
    game:get_item("equipment/sword_PLAYER"):set_variant(0)
    game:get_item("inventory/bow_PLAYER"):set_variant(0)
  end
end)

-- SALLE VERTE : COMMENTAIRES DU DÉVELOPPEUR
function open_weblink_dev_commentary:on_activated()
  os.execute("start https://www.youtube.com/playlist?list=PLKWst62bm03JA1plWGpucFIWBm651D76A")
  sol.timer.start(map, 500, function() open_weblink_dev_commentary:set_activated(false) end)
end

-- SALLE VIOLETTE : LIEN DE DL POUR PROTO JEU
function open_weblink_proto_dl:on_activated()
  os.execute("start https://www.mediafire.com/file/trztcn37n3du5xx/1ere_quete_proto.zip/file")
  sol.timer.start(map, 500, function() open_weblink_proto_dl:set_activated(false) end)
end

-- ÉNIGME ORDRE DE SWITCHES (4 2 3 1)
local switches_sequence = 0
function tiles_puzzle_switch_4:on_activated()
  if switches_sequence == 0 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_2:on_activated()
  if switches_sequence == 1 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_3:on_activated()
  if switches_sequence == 2 then
    switches_sequence = switches_sequence + 1
  else switches_sequence = 0 end
end
function tiles_puzzle_switch_1:on_activated()
  if switches_sequence == 3 then
    tiles_puzzle_switch_1:set_activated(true)
    tiles_puzzle_switch_2:set_activated(true)
    tiles_puzzle_switch_3:set_activated(true)
    tiles_puzzle_switch_4:set_activated(true)
    tiles_puzzle_switch_1:set_locked(true)
    tiles_puzzle_switch_2:set_locked(true)
    tiles_puzzle_switch_3:set_locked(true)
    tiles_puzzle_switch_4:set_locked(true)
    auto_switch_auto_door_4:on_activated()
  else switches_sequence = 0 end
end
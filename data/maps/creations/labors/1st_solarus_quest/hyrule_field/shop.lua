local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic1")
    hero:set_sword_sprite_id("npc/playing_character/link_1st_solarus_quest/sword2")
    if game:get_value("get_shield_10016") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2")
    else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1") end

    -- Boomerang acheté
    if game:get_value("get_boomerang_10016") then
        if article_green_potion ~= nil then article_green_potion:set_enabled(true) end
    end

    -- Pierre de Souvenir achetée
    if game:get_value("remembrance_shard_10016_1") then article_fairy:set_enabled(true) end

    -- Bouclier acheté
    if game:get_value("get_shield_10016") then
        if article_blue_potion ~= nil then article_blue_potion:set_enabled(true) end
    -- Trophée acheté
    elseif game:get_value("get_trophy_10016") then article_shield:set_enabled(true) end

end)

-- EMPLOYÉ CARTE DE FIDÉLITÉ
function card_employee:on_interaction()
    -- Tout obtenu : Félicitations !
    if game:get_value("get_fidelity_card_10016_5") then
        game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_allclear")
    -- Rang VIP
    elseif game:get_value("get_fidelity_card_10016_4") then
        if game:get_item("quest_items/fidelity_card_1st_solarus_quest"):get_amount() == 99 then
            game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_give_vip",function()
                hero:start_treasure("quest_items/fidelity_card_1st_solarus_quest",5,"get_fidelity_card_10016_5",function()
                    auto_switch_auto_door_5:on_activated()
                    sol.timer.start(map, 3500, function() card_employee:on_interaction() end)
                end)
            end)            
        else game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_vip_next") end  
    -- Rang Or
    elseif game:get_value("get_fidelity_card_10016_3") then
        if game:get_item("quest_items/fidelity_card_1st_solarus_quest"):get_amount() >= 50 then
            game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_give_gold",function()
                hero:start_treasure("quest_items/fidelity_card_1st_solarus_quest",4,"get_fidelity_card_10016_4",function()
                    auto_switch_auto_door_4:on_activated()
                    sol.timer.start(map, 4000, function() card_employee:on_interaction() end)
                end)
            end)            
        else game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_gold_next") end  
    -- Rang Argent
    elseif game:get_value("get_fidelity_card_10016_2") then
        if game:get_item("quest_items/fidelity_card_1st_solarus_quest"):get_amount() >= 25 then
            game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_give_silver",function()
                hero:start_treasure("quest_items/fidelity_card_1st_solarus_quest",3,"get_fidelity_card_10016_3",function()
                    auto_switch_auto_door_3:on_activated()
                    sol.timer.start(map, 4000, function() card_employee:on_interaction() end)
                end)
            end)            
        else game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_silver_next") end    
    -- Rang Bronze
    elseif game:get_value("get_fidelity_card_10016_1") then
        if game:get_item("quest_items/fidelity_card_1st_solarus_quest"):get_amount() >= 10 then
            game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_give_bronze",function()
                hero:start_treasure("quest_items/fidelity_card_1st_solarus_quest",2,"get_fidelity_card_10016_2",function()
                    auto_switch_auto_door_2:on_activated()
                    sol.timer.start(map, 3000, function() card_employee:on_interaction() end)
                end)
            end)            
        else game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_bronze_next") end
    -- Donne Carte
    else
        game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.card_employee_card_give",function()
            hero:start_treasure("quest_items/fidelity_card_1st_solarus_quest",1,"get_fidelity_card_10016_1",function()
                auto_switch_auto_door_1:on_activated()
                sol.timer.start(map, 3000, function() card_employee:on_interaction() end)
            end)
        end)
    end

end

-- ACHAT DES ARTICLES DU MAGASIN QUI DONNENT DES POINTS DE FIDÉLITÉ (10 Rubis = 1 Point)
function map:on_obtained_treasure(item, variant)
    -- Pile de Coeurs : 1 Point
    if item == game:get_item("pickable/hearts_pile") then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(1) end
    -- Flasque de Magie : 2 Points
    if item == game:get_item("pickable/magic_flask") and variant == 2 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(2) end
    -- Lot de Flèches (10) : 3 Points
    if item == game:get_item("pickable/arrow") and variant == 3 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(3) end
    -- Paquet de Bombes (10) : 4 Points
    if item == game:get_item("pickable/bomb") and variant == 3 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(4) end
    -- Potion rouge : 6 Points
    if item == game:get_item("other/red_potion") then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(6) end
    -- Potion verte : 4 Points
    if item == game:get_item("other/green_potion") then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(4) end
    -- Potion bleue : 10 Points
    if item == game:get_item("other/blue_potion") then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(10) end
    -- Boomerang magique : 10 Points
    if item == game:get_item("inventory/boomerang") and variant == 2 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(10) end
    -- Lot de Flèches (30) : 6 Points
    if item == game:get_item("pickable/arrow") and variant == 4 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(6) end
    -- Paquet de Bombes (20) : 8 Points
    if item == game:get_item("pickable/bomb") and variant == 4 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(8) end
    -- Éclat de Souvenir : 20 Points
    if item == game:get_item("quest_items/remembrance_shard_1st_solarus_quest") and variant == 2 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(20) end
    -- Fée : 7 Points
    if item == game:get_item("pickable/fairy") then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(7) end
    -- Bouclier Bling-bling : 30 Points
    if item == game:get_item("equipment/shield_1st_solarus_quest") and variant == 2 then game:get_item("quest_items/fidelity_card_1st_solarus_quest"):add_amount(30) end
end

-- BIENVENUE DES MARCHANDS DES DIVERSES SECTIONS
function welcome_grade_normal:on_activated()
    self:set_enabled(false)
    game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.welcome_grade_normal")
end
function welcome_grade_bronze:on_activated()
    self:set_enabled(false)
    game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.welcome_grade_bronze")
end
function welcome_grade_silver:on_activated()
    self:set_enabled(false)
    game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.welcome_grade_silver")
end
function welcome_grade_gold:on_activated()
    self:set_enabled(false)
    game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.welcome_grade_gold")
end
function welcome_grade_vip:on_activated()
    self:set_enabled(false)
    game:start_dialog("LABORS.1st_solarus_quest.hyrule_field.great_shop.welcome_grade_vip")
end

--PAS DE POTION SI PAS DE BOUTEILLE VIDE
if game:get_value("labors_bottle_1") then
    function article_red_potion:on_buying()
      local first_empty_bottle = self:get_game():get_first_empty_bottle()
      if first_empty_bottle == nil then
        sol.audio.play_sound("wrong")
        game:start_dialog("_shop.no_empty_bottle")
      else return true end
    end
    function article_green_potion:on_buying()
      local first_empty_bottle = self:get_game():get_first_empty_bottle()
      if first_empty_bottle == nil then
        sol.audio.play_sound("wrong")
        game:start_dialog("_shop.no_empty_bottle")
      else return true end
    end
    function article_blue_potion:on_buying()
        local first_empty_bottle = self:get_game():get_first_empty_bottle()
        if first_empty_bottle == nil then
          sol.audio.play_sound("wrong")
          game:start_dialog("_shop.no_empty_bottle")
        else return true end
      end
  end
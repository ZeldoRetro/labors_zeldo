-- Initialize npcs behavior specific to this quest.

require("scripts/multi_events")

local npc_meta = sol.main.get_metatable("npc")

-- FUNCTIONS TO MAKE THE NPCS WALK/RUN
local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  local speed = npc:get_property("walking_speed") or 32
  movement:set_speed(speed)
  movement:start(npc)
end

npc_meta:register_event("on_created", function(npc)
  local game = npc:get_game()
  local hero = game:get_hero()

  -- Disable the npc if the savegame value passed in property is true
  if npc:get_property("disable_if_value") ~= nil then
    if game:get_value(npc:get_property("disable_if_value")) then
      npc:set_enabled(false)
    end
  end

  -- Enable the npc if the savegame value passed in property is true
  if npc:get_property("enable_if_value") ~= nil then
    if game:get_value(npc:get_property("enable_if_value")) then
      npc:set_enabled(true)
    end
  end

  -- NPCs indiqués marchent/courent
  if npc:get_property("walking_npc") then
    npc_walk(npc)
  end

end)

function npc_meta:on_interaction()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  --Stèles
  if name:match("^ts") then
    game:set_dialog_style("stone")
    game:start_dialog(name)
  end

  --Statues de hibou
  if name:match("^owl") then
    game:set_dialog_style("stone")
    local game = map:get_game()
    if game:has_dungeon_stone_beak() then
      game:start_dialog(name)
    else
      sol.audio.play_sound("wrong")
      game:start_dialog("owl.no_beak")
    end
  end

  --Stèle à la fin du donjon: fais apparaitre un téléporteur vers l'entrée
  if name:match("^stele_telep_boss") then
    game:set_dialog_style("stone")
    game:start_dialog("ts.telep_boss",function()
      if not game:get_value("telep_boss_"..game:get_dungeon_index()) then
        local telep_x,telep_y = map:get_entity("telep_boss"):get_position()
        map:move_camera(telep_x,telep_y,256,function() 
          sol.audio.play_sound("secret")
          map:set_entities_enabled("telep_boss",true)
          game:set_value("telep_boss_"..game:get_dungeon_index(),true)  
        end)
      end
    end)
  end

  --Stèles en hylien
  if name:match("^hs") then
    game:set_dialog_style("stone")
    if not game:has_item("book_of_mudora") then
      sol.audio.play_sound("wrong")
      game:start_dialog("hs.need_book_of_mudora")
      return
    end
    game:start_dialog(name)
  end

  --Pancartes
  if name:match("^sign") then
    game:set_dialog_style("wood")
    game:start_dialog(name)
  end

  --Boites aux lettres
  if name:match("^mailbox") then
    game:set_dialog_style("wood")
    game:start_dialog(name)
  end

  --Livres
  if name:match("^book") then
    game:set_dialog_style("book")
    game:start_dialog(name)
  end

  --Soldats: disent un dialogue aléatoire
  if name:match("^soldier") then
    local i = math.random(5)
    game:start_dialog("hyrule_city.soldiers."..i)
  end

  --Soldats de Cocorico: dialogue pendant menace goriya sinon autre
  if name:match("^kakariko_soldier") then
    if game:get_value("viscen_vs_goriyas_quest") == 6 then
      game:start_dialog("hyrule_city.soldiers.kakariko")
    else
      game:start_dialog("hyrule_city.soldiers.kakariko_confined")
    end
  end

  --Prendre l'item clé du donjon s'il est sur un piédestal
  if name:match("key_item_pnj") then
    if game:get_map():get_entity("key_item") ~= nil then
      game:get_map():get_entity("key_item"):set_position(game:get_map():get_hero():get_position())
    else sol.audio.play_sound("wrong") game:start_dialog("_key_item_already_taken") end
  end

  -- Aubergistes: proposent de prendre une clé de chambre pour un certain montant
  if name:match("^aubergiste") then
    local price = tonumber(map:get_entity(name):get_property("key_price"))
  	if game:get_value("get_inn_key") then
  		game:start_dialog("inn.good_stay")
  	else
  		game:start_dialog("inn.question",price,function(answer)
        if answer == 1 then
          if game:get_money() >= price then
            game:remove_money(price)
         	  game:start_dialog("inn.answer_yes", function()
              hero:start_treasure("other/inn_key", 1, "get_inn_key")
            end)
          else
            sol.audio.play_sound("wrong")
            game:start_dialog("inn.no_money")
          end
        else
          game:start_dialog("inn.answer_no")
        end
  		end)
  	end
  end

  --Lit pour dormir: Passage jour/nuit + Restauration d'une partie de la santé
  if name:match("^bed") then
    game:start_dialog("inn.bed.rest",function(answer)
      if answer == 1 then
  			sol.audio.play_sound("day_night")
   			if game:get_value("night") or game:get_value("dawn") then
          game:set_value("daytime", 1)
          game:set_value("day",true)
          game:set_value("twilight",false) 
          game:set_value("night",false)
          game:set_value("dawn",false)			
  			else
          game:set_value("daytime", 4)
          game:set_value("day",false)
          game:set_value("twilight",false) 
          game:set_value("night",true)
          game:set_value("dawn",false)
   			end 
   			hero:teleport(game:get_map():get_id(),"sortie_lit","fade")  
        sol.timer.start(600,function()
          game:set_life(game:get_max_life())
          game:set_pause_allowed(false)
          game:get_map():get_entity("snores"):set_enabled(true)
          game:get_map():get_entity("snores"):get_sprite():set_ignore_suspend(true)
          game:get_map():get_entity("bed"):get_sprite():set_animation("hero_sleeping")
          game:get_map():get_entity("bed"):get_sprite():set_direction(game:get_ability("tunic") - 1)
          hero:set_visible(false)
          sol.timer.start(map, 700, function()
            hero:freeze()
            -- Begin dialog
            game:get_map():set_entities_enabled("exit",false)
            sol.timer.start(map, 2300, function()
              -- Wake up.
              game:get_map():get_entity("snores"):set_enabled(false)
              game:get_map():get_entity("bed"):get_sprite():set_animation("hero_waking")
              game:get_map():get_entity("bed"):get_sprite():set_direction(game:get_ability("tunic") - 1)
              sol.timer.start(1000,function()
                -- Jump from the bed.
                hero:unfreeze()
                hero:set_visible(true)
                hero:start_jumping(0, 24, true)
                game:set_pause_allowed(true)
                game:get_map():get_entity("bed"):get_sprite():set_animation("empty_open")
                sol.audio.play_sound("hero_lands")
              end)
            end)
          end)
       	end)
      end
    end)
  end
end

return true
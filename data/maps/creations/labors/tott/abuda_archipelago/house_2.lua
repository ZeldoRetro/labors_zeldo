local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
function map:on_started()

  --Etat des interrupteurs d'eau suivant le niveau de l'eau
  map:set_entities_enabled("water_middle",false)
  if game:get_value("labors_10006_island_village_drown_house_done") then 
    map:set_entities_enabled("water_low",true)
    switch_water_remove_1:set_activated(true) 
    map:set_entities_enabled("water_high",false)
    map:set_entities_enabled("water_flux",false)
  else map:set_entities_enabled("water_low",false) end
end

--DIALOGUES AVEC TIM : VIDER L'EAU CONTRE UN COQUILLAGE
function tim:on_interaction()
  if game:get_value("shell_10006_7") then
    game:start_dialog("LABORS.tott.abuda.tim_cleared")
  elseif game:get_value("labors_10006_island_village_drown_house_done") then
    game:start_dialog("LABORS.tott.abuda.tim_give_shard",function()
      hero:start_treasure("quest_items/shell",1,"shell_10006_7")
    end)
  elseif game:get_value("get_hookshot_10006") then
    game:start_dialog("LABORS.tott.abuda.tim_default")
  else game:start_dialog("LABORS.tott.abuda.tim_need_hook")
  end
end

--ACTIVATION DES INTERRUPTEURS ET GESTION DU NIVEAU DE L'EAU
function switch_water_remove_1:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.audio.play_sound("water_drain")
  sol.timer.start(1000,function()
    map:set_entities_enabled("water_high",false)
    map:set_entities_enabled("water_flux",false)
    map:set_entities_enabled("water_middle_1",true)
    sol.timer.start(1000,function()
      map:set_entities_enabled("water_middle_1",false)
      map:set_entities_enabled("water_middle_2",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("water_middle_2",false)
        map:set_entities_enabled("water_low",true)
        sol.audio.play_sound("secret")
        game:set_value("labors_10006_island_village_drown_house_done",true)
        hero:unfreeze()
      end)
    end)
  end)
end
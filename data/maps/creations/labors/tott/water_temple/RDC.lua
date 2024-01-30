local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.text_surface.create{
  text_key = "dungeon_10001.name",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)

  --Etat des interrupteurs d'eau suivant le niveau de l'eau
  map:set_entities_enabled("water_middle",false)
  map:set_entities_enabled("water_flux",false)
  if game:get_value("water_temple_water_level") == 4 then 
    switch_water_add_1:set_activated(true)
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
  else 
    switch_water_remove_1:set_activated(true) 
    map:set_entities_enabled("water_high",false)
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
        switch_water_add_1:set_activated(false)
        game:set_value("water_temple_water_level",3)
        hero:unfreeze()
      end)
    end)
  end)
end
function switch_water_add_1:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.audio.play_sound("water_fill")
  sol.timer.start(1000,function()
    map:set_entities_enabled("water_low",false)
    map:set_entities_enabled("water_flux_constant",true)
      map:set_entities_enabled("water_middle_2",true)
      map:set_entities_enabled("water_flux_1",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("water_middle_2",false)
        map:set_entities_enabled("water_middle_1",true)
        map:set_entities_enabled("water_flux_1",false)
        map:set_entities_enabled("water_flux_2",true)
        sol.timer.start(1000,function()
          map:set_entities_enabled("water_middle_1",false)
          map:set_entities_enabled("water_flux_2",false)
          map:set_entities_enabled("water_high",true)
          map:set_entities_enabled("water_miniboss",true)
          map:set_entities_enabled("water_boss",true)
          sol.audio.play_sound("secret")
          switch_water_remove_1:set_activated(false)
          game:set_value("water_temple_water_level",4)
          hero:unfreeze()
        end)
      end)
  end)
end
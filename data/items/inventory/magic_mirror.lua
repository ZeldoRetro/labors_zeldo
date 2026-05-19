local item = ...
local game = item:get_game()

local return_map
local return_dest

function item:on_created()

  -- Define the properties.
  self:set_savegame_variable("possession_magic_mirror")
  self:set_sound_when_picked(nil)
  self:set_assignable(true)
end

-- FONCTION RETOURNANT LA MAP RETOUR NÉCESSAIRE
local function get_return_map()
  local map = game:get_map()
  local world = map:get_world()

  -- Vague 1 - Tower of the Triforce
  if world == "dungeon_10001" -- Temple de l'Eau
  or world == "dungeon_10002" -- Tombe ancienne
  or world == "dungeon_10003" -- Caverne de Glace
  or world == "dungeon_10004" -- Temple du Feu
  or world == "dungeon_10005" -- Chutes d'Hylia
  or world == "dungeon_10006" -- Archipel d'Abuda
  or world == "outside_light_labors_tott"
  or world == "inside_world_labors_tott" then
    return_map = "creations/labors/tott/hub"
    return_dest = "start_wave_1"
  elseif world == "dungeon_10007" then -- Tour du Château
    return_map = "creations/labors/tott/hub"
    return_dest = "start_final"
  elseif world == "dungeon_1001" then -- Zone SPOIL - AHF : Ruines de l'Aigle
    return_map = "creations/labors/tott/hub"
    return_dest = "start_incoming"

  -- Vague 2 - 1st Solarus Quest
  elseif world == "dungeon_10011" -- Terrain de Link et Forêt
  or world == "dungeon_10012" -- Village du Lac
  or world == "dungeon_10013" -- Montagne d'Héra
  or world == "dungeon_10014" -- Temple de la Force
  or world == "dungeon_10015" then -- Temple de la Sagesse
    return_map = "creations/labors/1st_solarus_quest/hub"
    return_dest = "start_wave_1"
  elseif world == "dungeon_10016" -- Plaine d'Hyrule
  or world == "dungeon_10017" -- Château d'Hyrule
  or world == "dungeon_10019" then -- Village de la Forêt
    return_map = "creations/labors/1st_solarus_quest/hub"
    return_dest = "start_wave_2"
  elseif world == "dungeon_10018" then -- Château de Ganon
    return_map = "creations/labors/1st_solarus_quest/hub"
    return_dest = "start_final"
  elseif world == "dungeon_4_out" -- Zone SPOIL - Forgotten : Jardins Kokiri
  or world == "dungeon_4" then -- Zone SPOIL - Forgotten : Jardins Kokiri
    return_map = "creations/labors/1st_solarus_quest/hub"
    return_dest = "start_incoming"
  elseif world == "outside_light_labors_1st_solarus_quest" -- Maps générales intérieurs et extérieurs : Dépend de la map en cours
  or world == "inside_world_labors_1st_solarus_quest" then
    if string.find(map:get_id(), "creations/labors/1st_solarus_quest/forest_village/") == 1
    or string.find(map:get_id(), "creations/labors/1st_solarus_quest/hyrule_field/") == 1 then
      return_map = "creations/labors/1st_solarus_quest/hub"
      return_dest = "start_wave_2"
    else
      return_map = "creations/labors/1st_solarus_quest/hub"
      return_dest = "start_wave_1"
    end  

  -- Vague 3 - Retranscriptions
  elseif world == "dungeon_10021" -- Ruines de l'Aigle
  or world == "dungeon_10022" -- Palais de Parapa
  or world == "dungeon_10023" -- Ruines du Croissant
  or world == "outside_light_labors_retranscriptions"
  or world == "inside_world_labors_retranscriptions" then
    return_map = "creations/labors/retranscriptions/hub"
    return_dest = "start_wave_1"

  -- Manoir ou Hors Vague : Rien ne se passe
  else return "other" end
end

function item:on_using()
  get_return_map()
  if get_return_map() == "other" then sol.audio.play_sound("wrong")
  else sol.audio.play_sound("warp") game:get_map():get_hero():teleport(return_map, return_dest) end
  item:set_finished()
end
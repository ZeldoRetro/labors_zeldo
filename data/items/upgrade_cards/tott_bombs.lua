--Upgrade Card

local item = ...
local game = item:get_game()
local map = game:get_map()

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_tott_upgrade_card_bombs")
end

local function fake_activate()
  local variant = item:get_variant()

  if variant == 1 then
    game:set_value("tott_upgrade_card_bombs_active",true)
  else
    game:set_value("tott_upgrade_card_bombs_active",false)
  end
end

function item:on_using()
  local variant = item:get_variant()
  local current_bombs = game:get_item("inventory/bombs_counter"):get_amount()

  if variant == 1 then
    game:set_value("tott_upgrade_card_bombs_active",true)
    game:get_item("equipment/bomb_bag"):set_variant(2)
  else
    game:set_value("tott_upgrade_card_bombs_active",false)
    game:get_item("equipment/bomb_bag"):set_variant(1)
  end
  game:get_item("inventory/bombs_counter"):set_amount(current_bombs)
end

function item:on_variant_changed()

  local game = item:get_game()
  local map = game:get_map()

  -- EXCEPTION : EST-ON DANS UN LIEU OU ON DÉBLOQUERA LES BOMBES ?
  if map:get_world() == "dungeon_10015" then -- 1st Solarus Quest : Temple Sagesse
    if not game:get_value("get_bomb_bag_10015") then
      fake_activate()
      return
    end
  elseif item:get_game():get_map():get_world() == "dungeon_10017" then -- 1st Solarus Quest : Château d'Hyrule
    if not game:get_value("get_bomb_bag_10017") then
      fake_activate()
      return
    end
  elseif string.find(map:get_id(), "creations/labors/1st_solarus_quest/link_forest/") == 1 then -- 1st Solarus Quest : Terrain du départ
    if not game:get_value("labors_perma_bombs_wave_2") then
      fake_activate()
      return
    end
  elseif string.find(map:get_id(), "creations/labors/1st_solarus_quest/lake_village/") == 1 then -- 1st Solarus Quest : Village du Lac
    if not game:get_value("labors_perma_bombs_wave_2") then
      fake_activate()
      return
    end
  elseif string.find(map:get_id(), "creations/labors/1st_solarus_quest/hera_mountain/") == 1 then -- 1st Solarus Quest : Montagne d'Héra
    if not game:get_value("labors_perma_bombs_wave_2") then
      fake_activate()
      return
    end
  elseif map:get_world() == "dungeon_4" or map:get_id() == "creations/forgotten_legend/outside/light/sacred_forest_meadow" then -- Zone SPOIL - FL : Jardins Kokiri
    fake_activate()
    return
  elseif item:get_game():get_map():get_world() == "dungeon_10000" -- Manoir Oblivion
  or item:get_game():get_map():get_world() == "dungeon_10010"
  or item:get_game():get_map():get_world() == "dungeon_9999" then
    fake_activate()
    return
  end

  -- Sinon, on applique l'effet de la carte
  item:on_using()
end
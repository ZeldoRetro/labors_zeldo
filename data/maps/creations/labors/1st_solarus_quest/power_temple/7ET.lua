local map = ...
local game = map:get_game()

-- SWITCH QUI FAIT REVENIR LES POTS
local pot_placeholders = {
}

function pot_switch:on_activated()

  -- Create a skull at a random place.
  local index = math.random(#pot_placeholders)
  local placeholder = pot_placeholders[index]
  local x, y, layer = placeholder:get_position()
  local pot = map:create_destructible({
    x = x,
    y = y,
    layer = layer,
    treasure_name = "pickable/random",
    sprite = "entities/Destructables/vase_very_heavy",
    weight = 2,
    destruction_sound = "vase",
    can_be_cut = false,
    damage_on_enemies = 4,
  })
  pot:bring_to_back() -- Workaround : Ensure the created destructible is under a possible invisible entity such as lights, to let it liftable again after thrown.

  function pot:on_removed()

    if pot_switch == nil then
      -- The map is being unloaded.
      return
    end
    
    -- Make the switch usable again.
    pot_switch:set_activated(false)
  end
end

-- Boss qui referme l'escalier derrière nous
sensor_boss:register_event("on_activated",function()
  map:set_entities_enabled("boss_lock",false)
end)

map:register_event("on_started",function(map, destination)
    -- Boss vaincu et trophée disponible si pas ramassé
    if not game:get_value("get_trophy_10014") then
      if game:get_value("boss_"..game:get_dungeon_index()) then 
        local x, y, layer = map:get_entity("trophy_spot"):get_position()
        map:create_pickable{
          treasure_name = "quest_items/trophy_labors_1st_solarus_quest",
          treasure_variant = 1,
          treasure_savegame_variable = "get_trophy_"..game:get_dungeon_index(),
          x = x,
          y = y,
          layer = layer
        }
      end
    end

    --Vases aléatoires
    for placeholder in map:get_entities("pot_placeholder") do
      -- Avoid facing entity conflict with skulls (Solarus issue #1042).
      placeholder:set_enabled(false)
      pot_placeholders[#pot_placeholders + 1] = placeholder
    end
end)

-- Événement exceptionnel après le boss: cutscene de Vire et Trophée apparait
if boss ~= nil then
   boss:register_event("on_dead",function()
    sol.timer.start(map, 1000, function()

          local x, y, layer = map:get_entity("trophy_spot"):get_position()
          map:create_pickable{
            treasure_name = "quest_items/trophy_labors_1st_solarus_quest",
            treasure_variant = 1,
            treasure_savegame_variable = "get_trophy_"..game:get_dungeon_index(),
            x = x,
            y = y,
            layer = layer
          }
    end)
  end)
end
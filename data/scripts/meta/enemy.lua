-- Initialize enemy behavior specific to this quest.

require("scripts/multi_events")
local entity_manager= require("scripts/entity_manager") 

local enemy_meta = sol.main.get_metatable("enemy")

enemy_meta:register_event("on_created", function(enemy)
  local game = enemy:get_game()
  local hero = game:get_hero()
  local name = enemy:get_name()



  if name == nil then
    return
  end
  if name:match("^invisible_enemy") then
    enemy:set_visible(false)
  end

end)

-- Redefine how to calculate the damage inflicted by the sword.
function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)

  local force = hero:get_game():get_value("force")
  local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
  -- Multiply the sword consequence by the force of the hero.
  local life_lost = reaction * force
  if hero:get_state() == "sword spin attack" then
    -- And multiply this by 2 during a spin attack.
    life_lost = life_lost * 2
  end
  self:remove_life(life_lost)
end

-- Helper function to inflict an explicit reaction from a scripted weapon.
-- TODO this should be in the Solarus API one day
function enemy_meta:receive_attack_consequence(attack, reaction)

  if type(reaction) == "number" then
    self:hurt(reaction)
  elseif reaction == "immobilized" then
    self:immobilize()
  elseif reaction == "protected" then
    sol.audio.play_sound("sword_tapping")
  elseif reaction == "custom" then
    if self.on_custom_attack_received ~= nil then
      self:on_custom_attack_received(attack)
    end
  end

end


function enemy_meta:on_dead()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()
  local music_map = map:get_music()
  if map:get_world() == "dungeon_100" then music_map = "creations/forgotten_legend/hyrule_castle_dark" end

  --Compteur d'ennemis morts (récompense après x ennemis tués?)
  local death_count = game:get_value("enemy_death_counter") or 0
  game:set_value("enemy_death_counter", death_count + 1)

  if name == nil then
    return
  end

  --Miniboss
  if name:match("^miniboss") then
    if not map:has_entities("miniboss") then
      local door_x, door_y = map:get_entity("door_miniboss_2"):get_position()
      sol.audio.play_sound("correct")
      map:move_camera(door_x + 8,door_y,256,function() 
        map:open_doors("door_miniboss") 
        map:set_entities_enabled("telep_miniboss",true)
        map:set_entities_enabled("path_miniboss",true)
        game:set_value("miniboss_"..game:get_dungeon_index(),true)
        sol.audio.play_music(music_map)
      end)
    end
  end
end

--Boss: freeze le jeu pendant sa mort et fait apparaitre un réceptacle au milieu de la pièce
enemy_meta:register_event("on_dying", function(enemy)
  local game = enemy:get_game()
  local name = enemy:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  if name:match("^boss") then
    local door_x, door_y = map:get_entity("door_boss_2"):get_position()
    hero:freeze()
    game:set_pause_allowed(false)
    sol.audio.play_music("none")
    sol.timer.start(6000,function()
      sol.audio.play_sound("correct")
      map:move_camera(door_x + 8,door_y,256,function()  
        map:open_doors("door_boss_2")
        map:set_entities_enabled("boss_lock",false)
        game:set_pause_allowed(true)
        hero:unfreeze()
        sol.audio.play_music("after_boss")
        map:set_entities_enabled("after_boss",true)
        local x, y, layer = map:get_entity("heart_container_spot"):get_position()
        enemy:get_map():create_pickable{
          treasure_name = "quest_items/remembrance_shard",
          treasure_variant = 3,
          treasure_savegame_variable = "heart_container_"..game:get_dungeon_index(),
          x = x,
          y = y,
          layer = layer
        }
      end)
    end)
  end
end)

enemy_meta:register_event("on_removed", function(enemy)

    local game = enemy:get_game()
    local map = game:get_map()
    if enemy:get_ground_below()== "hole" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_falling_entity(enemy)
    elseif enemy:get_ground_below()== "deep_water" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_drowning_entity(enemy)
    elseif enemy:get_ground_below()== "lava" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_burning_entity(enemy)
    end
end)

enemy_meta:register_event("on_attacking_hero", function(enemy)
  local game = enemy:get_game()
  if game:get_value("starman") then enemy:set_life(0)
  else game:get_map():get_hero():start_hurt(enemy, enemy:get_damage()) end

  --Wooden shield burn if the enemy is a fire one
  if game:get_value("get_shield_1") then
    if enemy:get_breed() == "fireball_red_small" or enemy:get_breed() == "fireball_red_small_light" or enemy:get_breed() == "bubble_red" or enemy:get_breed() == "keese_fire" or enemy:get_breed() == "flame_red" then
      sol.timer.start(game, 1000, function()
        local x, y, layer = enemy:get_map():get_hero():get_position()
        enemy:get_map():create_custom_entity{
          model = "fire",
          x = x ,
          y = y,
          layer = layer + 1,
          width = 16,
          height = 16,
          direction = 0,
        }
        game:start_dialog("_shield_burn",function()
          game:set_ability("shield",0)
          game:set_value("get_shield_1",false)
          game:set_value("first_shield",false)
          game:get_item("equipment/shield"):set_variant(0)
          local defense = game:get_value("defense")
          defense = defense - 1
          game:set_value("defense", defense)
        end)
      end)
    end
  end
end)

return true
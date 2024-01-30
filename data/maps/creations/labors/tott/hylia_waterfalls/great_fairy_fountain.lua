local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
function map:on_started()

  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then map:set_entities_enabled("day_entity",true) else map:set_entities_enabled("day_entity",false) end

  if game:get_value("great_fairy_10005_offering_done") then
    --Offrande faite: Musique différente et apparition de fées
    sol.audio.play_music("great_fairy")
    map:set_entities_enabled("fairy",true)
  else map:set_entities_enabled("fairy",false) end 
  map:set_entities_enabled("great_fairy",false)
end

--ANIMATION DE LA BENEDICTION
local hearts = {}
-- Creates hearts around the hero and launch animation
function create_hearts(map, index, fairy_name, hearts, music_name)

        local hero = map:get_hero()
        local x, y, layer = hero:get_position()
        local radius = 40
        sol.timer.start(map, 150, function()
            if (index < 8) then
              local position_x = x
              local position_y = y
              if index == 0 then
                position_y = position_y - radius
              end
              if index == 1 then
                position_y = position_y - radius*math.sin(45 * math.pi / 180)
                position_x = position_x + radius*math.cos(45  * math.pi / 180)
              end
              if index == 2 then
                position_x = position_x + radius
              end
              if index == 3 then
                position_y = position_y + radius*math.sin(135 * math.pi / 180)
                position_x = position_x - radius*math.cos(135  * math.pi / 180)
              end
              if index == 4 then
                position_y = position_y + radius
              end
              if index == 5 then
                position_y = position_y - radius*math.sin(225 * math.pi / 180)
                position_x = position_x + radius*math.cos(225  * math.pi / 180)
              end
              if index== 6 then
                position_x = position_x - radius
              end
              if index == 7 then
                position_y = position_y + radius*math.sin(315 * math.pi / 180)
                position_x = position_x - radius*math.cos(315  * math.pi / 180)
              end
              hearts[index] = map:create_custom_entity({
                sprite = "entities/Decorations/fairy_blue",
                x = position_x,
                y = position_y,
                width = 8,
                height = 8,
                layer = 2,
                direction = 0
              })
              index = index + 1
              sol.audio.play_sound("fairy")
              create_hearts(map, index, fairy_name, hearts, music_name)
            else
              animate_hearts(map, fairy_name, hearts, music_name)
            end
        end)
end


-- Animate Hearts and finished the care
function animate_hearts(map, fairy_name, hearts, music_name)

  local radius = 40
  local hero = map:get_hero()
  for index = 0, 7, 1 do
    local heart  = hearts[index]
    local angle = 0
    if index == 0 then
      angle = 0
    end
    if index == 1 then
      angle = 45
    end
    if index == 2 then
      angle = 90
    end
    if index == 3 then
      angle = 135
    end
    if index == 4 then
      angle = 180
    end
    if index == 5 then
      angle = 225
    end
    if index== 6 then
      angle = 270
    end
    if index == 7 then
      angle = 315
    end
    local m = sol.movement.create("circle")
    m:set_center(hero)
    m:set_radius(radius)
    m:set_radius_speed(50)
    m:set_max_rotations(4)
    m:set_angle_speed(360)
    m:set_initial_angle(angle)
    m:set_ignore_obstacles(true)
    if index == 7 then
      m:start(heart, function() 
        for index = 0, 7, 1 do
            local heart  = hearts[index]
            heart:remove()
        end
        return
      end)
    else
      m:start(heart)
    end
  end
end

--PREMIERE APPARITION DE LA FEE:BENEDICTION
local function great_fairy_1st_time()
    local fairy = map:get_entity("great_fairy")
    game:set_value("great_fairy_10005_offering_done",true)
    game:start_dialog("LABORS.tott.great_fairy_waterfall.1st_time", function()
      --Animation bénédiction
      create_hearts(map, 0, "great_fairy", hearts, "fairy")
      sol.timer.start(6000,function()
        game:set_life(game:get_max_life())
        game:set_magic(game:get_max_magic())
          hero:start_treasure("quest_items/trophy_labors_tott",1,"get_trophy_10005",function()
              fairy:get_sprite():fade_out(100, function() end)
          end) 
      end)
    end)
end

--APPARITION DE LA GRANDE FEE
local function great_fairy_benediction()
  sensor_great_fairy:set_enabled(false)
  local fairy = map:get_entity("great_fairy")
  game:set_suspended(true)
  fairy:get_sprite():set_ignore_suspend(true)
  fairy:set_enabled(true)
  sol.audio.play_music("great_fairy")
  fairy:get_sprite():fade_in(100, function()
    if not game:get_value("great_fairy_10005_offering_done") then
      --Première apparition: Don de la bénédiction  
      great_fairy_1st_time()  
    else
      --Fée déjà vue: on soigne simplement le héros
      game:start_dialog("LABORS.tott.great_fairy_waterfall.welcome",function()
        --Animation bénédiction
        create_hearts(map, 0, "great_fairy", hearts, "fairy")
        sol.timer.start(6000,function()
          game:set_life(game:get_max_life())
          game:set_magic(game:get_max_magic())
          game:start_dialog("LABORS.tott.great_fairy_waterfall.goodbye",function()
            fairy:get_sprite():fade_out(100, function()
              hero:unfreeze()
              game:set_suspended(false)
            end)
          end)
        end)
      end)
    end
  end)
end

--SENSOR POUR ACTIVER LA GRANDE FEE
function sensor_great_fairy:on_interaction()
    hero:set_direction(1)
    if game:get_value("great_fairy_10005_offering_done") then
      hero:freeze()
      --Offrande déjà faite:La Grande Fée apparait à volonté
      great_fairy_benediction()
    else
      --Première apparition: on jette les fragments de puissance à l'eau
      game:start_dialog("LABORS.tott.great_fairy_waterfall.offering_question",function(answer)
        if answer == 1 then
          if game:get_item("quest_items/fairy_power_fragment"):get_amount() >= 5 then
            game:get_item("quest_items/fairy_power_fragment"):remove_amount(5)
            hero:freeze()
            hero:set_animation("carrying_stopped")
            local x_hero,y_hero, layer_hero = hero:get_position()
            local fragment_sprite = map:create_custom_entity({
               name = "fragment_sprite",
               sprite = "entities/items",
               x = x_hero,
               y = y_hero - 18,
               width = 16,
               height = 16,
               layer = layer_hero + 1,
               direction = 0
            })
            fragment_sprite:get_sprite():set_animation("quest_items/fairy_power_fragment")
            fragment_sprite:get_sprite():set_direction(0)
            sol.timer.start(500,function()
              hero:set_animation("stopped")
              sol.audio.play_sound("throw")
              local m = sol.movement.create("straight")
              m:set_angle(math.pi /2)
              m:set_max_distance(56)
              m:set_speed(144)
              m:start(fragment_sprite,function()
                fragment_sprite:set_enabled(false)
                sol.audio.play_sound("splash")
                sol.timer.start(1500,function() great_fairy_benediction() end)
              end)
            end)
          else
            sol.audio.play_sound("wrong")
            game:start_dialog("LABORS.tott.great_fairy_waterfall.not_enough_fragments")
          end
        end    
      end)
    end
end

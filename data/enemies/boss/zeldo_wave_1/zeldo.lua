-- Lua script of enemy bosses/zeldo/zeldo.


-- _-_ SET VARIABLE _-_

local enemy = ...
local x, y, layer = enemy:get_position()
local max_life = 0
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local shadow_spr
local element_card = {}
local movement = sol.movement.create("target")
local var_1 = 0
local var_2 = 1
local frame = 0
local state = 0
local sound_list = {}
local first_x_spawn, first_y_spawn, first_layer_spawn = enemy:get_position()
sound_list[0] = "zora" -- lorsque des projectiles sont spawn
sound_list[1] = "boss_charge" -- zeldo lorsqu il s envole
sound_list[2] = sol.language.get_language().."/zeldo_wave_1_voice/laugh" -- rire de zeldo
sound_list[3] = "walk_on_grass" -- lorsque certaines cartes sont envoyees
sound_list[4] = sol.language.get_language().."/zeldo_wave_1_voice/attack_fire" -- attaque feu
sound_list[5] = sol.language.get_language().."/zeldo_wave_1_voice/attack_fly" -- attaque vol
sound_list[6] = sol.language.get_language().."/zeldo_wave_1_voice/attack_water" -- attaque eau
sound_list[7] = sol.language.get_language().."/zeldo_wave_1_voice/attack_cards" -- attaque cartes
local card_projectile_id = "boss/zeldo_wave_1/card_projo"

local id_dialog_1 = "door.closed.1" -- lorsqu'il utilise la "desperate move"
local id_dialog_2 = "door.closed.2" -- lorsqu'il est definitivement tuee

movement:set_target(hero)
movement:set_speed(48)

-- function remind
  --movement:start(enemy)
  --map:remove_entities("projo")

-- Ecrire ceci pour remettre le mod normal
function enemy:stop_the_joke()
  state = 0
  enemy:set_damage(2)
  var_2 = 6
  enemy:restart()
end

function enemy:restart_fight()
  sol.timer.stop_all(enemy)
  state = -2
  enemy:restart()
end

local function reset_attack_reaction()
  --enemy:set_default_attack_consequences()
  enemy:set_attack_consequence("sword", 1)
end

local function disable_attack_reaction()
  enemy:set_invincible()
end

local function immobilize_attack_reaction()
  disable_attack_reaction()
  enemy:set_attack_consequence("sword", "immobilized")
end

local function on_immobilized_attack_reaction()
  disable_attack_reaction()
  enemy:set_attack_consequence("sword", 1)
end

-- _-_ CUSTOM ENTITIES _-_

local function spawn_card(x, y, layer, skin, mode, angle)
  map:create_enemy({
    name = ("zeldo_"..tostring(enemy).."_card"),
    breed = card_projectile_id,
    layer = layer,
    x = x,
    y = y,
    direction = skin,
    properties = {
      {
        key = "mode",
        value = tostring(mode),
      },
      {
        key = "angle",
        value = tostring(angle),
      },
      {
        key = "var_2",
        value = tostring(var_2),
      },
    },
  })
end

local function spawn_projo_source(x, y, layer, skin, mode, angle, speed_source, angle_source, animation)
  local projo_source = map:create_custom_entity({
    name = ("zeldo_"..tostring(enemy).."_projosource"),
    direction = 0,
    x = x,
    y = y,
    layer = layer,
    width = 8,
    height = 8,
    sprite = "enemies/" .. card_projectile_id,
    properties = {
        {
          key = "mode",
          value = tostring(mode),
        },
        {
          key = "angle",
          value = tostring(angle),
        },
      }
    })
  local entity_id = map:get_entity(projo_source:get_name())
  entity_id:get_sprite():set_animation(animation)
  entity_id.projo_source_movement = sol.movement.create("straight")
  entity_id.projo_source_movement:set_speed(speed_source)
  entity_id.projo_source_movement:set_angle(math.rad(angle_source))
  entity_id.projo_source_movement:set_smooth(false)
  entity_id.projo_source_movement:start(entity_id)
  function entity_id.projo_source_movement:on_obstacle_reached()
    local x_temp, y_temp, layer_temp = entity_id:get_position()
    spawn_card(x_temp, y_temp, layer_temp, 0, 3, 0)
    entity_id:remove()
  end
  sol.timer.start(entity_id, 875*var_2, function()
    local x_temp, y_temp, layer_temp = entity_id:get_position()
    spawn_card(x_temp, y_temp, layer_temp, 0, 3, 0)
    entity_id:remove()
  end)
  sol.timer.start(entity_id, 300*var_2, function()
    local projo_mode = tonumber(entity_id:get_property("mode"))
    local angle_movement = tonumber(entity_id:get_property("angle"))
    local x_temp, y_temp, layer_temp = entity_id:get_position()
    sol.audio.play_sound(sound_list[3])
    spawn_card(x_temp, y_temp, layer_temp, 3, projo_mode, angle_movement)
    return true
  end)
end

-- _-_ ENEMY SCRIPT _-_

function enemy:on_created()
  shadow_spr = enemy:create_sprite("enemies/" .. enemy:get_breed())
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  element_card[0] = enemy:create_sprite("enemies/" .. card_projectile_id)
  element_card[1] = enemy:create_sprite("enemies/" .. card_projectile_id)
  element_card[0]:set_opacity(0)
  element_card[1]:set_opacity(0)
  shadow_spr:set_color_modulation({0,0,0,150})
  shadow_spr:set_scale(1,0.25)
  enemy:set_life(64)
  max_life = enemy:get_life()
  enemy:set_damage(8)
  enemy:set_invincible()
  enemy:set_attacking_collision_mode("overlapping")
end

function enemy:on_immobilized()
  state = 1
  on_immobilized_attack_reaction()
end

function enemy:on_restarted()
  if state == 0 then
    element_card[0]:set_opacity(0)
    element_card[1]:set_opacity(0)
    element_card[0]:set_animation("walking")
    element_card[1]:set_animation("walking")
    element_card[0]:set_direction(4)
    element_card[1]:set_direction(5)
    sprite:set_animation("flying")
    state = math.random(3,12)
    enemy:set_can_attack(true)
    sprite:set_xy(0, 0)
  end

  local life_difficulty_calcul = 1-(enemy:get_life()/max_life)
  if var_2 <= 1 then
    life_difficulty_calcul = 1
  end

  if state == 1 then -- tp after hurt
    element_card[0]:set_opacity(0)
    element_card[1]:set_opacity(0)
    frame = 0
    enemy:set_can_attack(false)
    disable_attack_reaction()
    local i = 0

    sol.timer.start(enemy, (7-(life_difficulty_calcul*3))*math.min(var_2,2), function()
      i = i+0.05
      sprite:set_scale(1-i, 1+i)
      shadow_spr:set_opacity(255-(i*255))
      if i < 1 then
        return true
      else
        sprite:set_opacity(0)
        shadow_spr:set_opacity(0)
        sprite:set_scale(1, 1)
        state = 2
        enemy:restart()
      end
    end)
  elseif state == 2 then -- reappear
    local previous_x, previous_y = x, y
    local i = 0
    enemy:set_can_attack(false)
    sol.timer.start(enemy, (7-(life_difficulty_calcul*3))*math.min(var_2,2), function()
      i = i+1
      previous_x, previous_y = x, y
      x = x+(math.cos(math.random(0,360))*(32))
      y = y-(math.sin(math.random(0,360))*(32))
      if not enemy:test_obstacles(x-previous_x, y-previous_y) then
        enemy:set_position(x, y, layer)
      else
        x, y = previous_x, previous_y
      end
      if i < 20 then
        return true
      else
        sprite:set_opacity(255)
        i = 0
        sol.timer.start(enemy, (7-(life_difficulty_calcul*3))*math.min(var_2,2), function()
          i = i+0.05
          sprite:set_scale(0+i, 2-i)
          shadow_spr:set_opacity(i*255)
          if i < 1 then
            return true
          else
            sprite:set_opacity(255)
            shadow_spr:set_opacity(255)
            sprite:set_scale(1, 1)
            state = 0
            enemy:restart()
          end
        end)
      end
    end)
  elseif state == 3 then -- attack fire on ground
    sol.audio.play_sound(sound_list[4])
    element_card[1]:set_direction(6)
    element_card[0]:set_color_modulation({255,160,160})
    element_card[1]:set_color_modulation({125,0,0})
    for i = 0, 1 do
      element_card[i]:set_opacity(255)
      element_card[i]:set_xy(10, -22)
    end
    immobilize_attack_reaction()
    state = 1
    sprite:set_animation("spell")
    enemy:set_can_attack(true)
    local i = 0
    local j = 0
    var_1 = 0
    sol.timer.start(enemy, 100, function()
      j = j+1
      local temp_calcul = (math.sin(j)*32)+32
      element_card[0]:set_color_modulation({255-temp_calcul,160+temp_calcul,160+temp_calcul})
      element_card[1]:set_color_modulation({125+temp_calcul,temp_calcul,temp_calcul})
      if sprite:get_animation() == "spell" then
        return true
      end
    end)
    sol.timer.start(enemy, (200-(life_difficulty_calcul*120))*var_2, function()
      sol.audio.play_sound(sound_list[0])
      i = i+1
      x, y, layer = enemy:get_position()
      spawn_projo_source(x, y, layer, 5, 2, var_1, (64-(32*i))*var_2, var_1, "fire")
      spawn_projo_source(x, y, layer, 5, 2, var_1, (64-(32*i))*var_2, (var_1+120)%360, "fire")
      spawn_projo_source(x, y, layer, 5, 2, var_1, (64-(32*i))*var_2, (var_1+240)%360, "fire")
      var_1 = var_1+60
      if var_1 > 359 then var_1 = var_1-360 end
      if i < 5 then
        return true
      else
        for i = 0, 1 do
          element_card[i]:set_opacity(0)
        end
        reset_attack_reaction()
        sprite:set_animation("protect")
        sol.timer.start(enemy, 2000-(life_difficulty_calcul*1500), function()
          enemy:restart()
        end)
      end
    end)
  elseif state == 4 then --fly and card
    sol.audio.play_sound(sound_list[5])
    disable_attack_reaction()
    enemy:set_can_attack(false)
    state = 1
    sprite:set_animation("flying")
    var_1 = 0
    sol.audio.play_sound(sound_list[1])
    local i = 0
    sol.timer.start(enemy, 10, function()
      i = i+1
      sprite:set_xy(0, 0-(i))
      if i < 64 then
        return true
      else
        sol.timer.start(enemy, (60-(life_difficulty_calcul*40))*var_2, function()
          if sprite:get_animation() == "flying" then
            sol.audio.play_sound(sound_list[3])
            spawn_card(x, y, layer, 1, 1, var_1)
            var_1 = var_1+180+i*3.2
            if var_1 > 359 then var_1 = var_1-360 end
            return true
          end
        end)
        sol.timer.start(enemy, 5000, function()
          sol.timer.start(enemy, 10, function()
            i = i-1
            sprite:set_xy(0, 0-(i))
            if i > 0 then
              return true
            else
              enemy:set_can_attack(true)
              sprite:set_xy(0, 0)
              if math.random(0,2) == 0 then
                sol.audio.play_sound(sound_list[2])
                immobilize_attack_reaction()
                sprite:set_animation("laughing")
                sol.timer.start(enemy, (250-(life_difficulty_calcul*200))*var_2, function()
                  reset_attack_reaction()
                  sprite:set_animation("stopped")
                  sol.timer.start(enemy, (500-(life_difficulty_calcul*450))*var_2, function()
                    enemy:restart()
                  end)
                end)
              else
                reset_attack_reaction()
                sprite:set_animation("stopped")
                sol.timer.start(enemy, (750-(life_difficulty_calcul*700))*var_2, function()
                  enemy:restart()
                end)
              end
            end
          end)
        end)
      end
    end)
  elseif state == 5 then -- attack water on ground
    sol.audio.play_sound(sound_list[6])
    immobilize_attack_reaction()
    element_card[1]:set_direction(5)
    element_card[0]:set_color_modulation({160,230,255})
    element_card[1]:set_color_modulation({0,65,125})
    for i = 0, 1 do
      element_card[i]:set_opacity(255)
      element_card[i]:set_xy(10, -22)
    end
    state = 1
    sprite:set_animation("spell")
    enemy:set_can_attack(true)
    local i = 0
    local j = 0
    sol.timer.start(enemy, 100, function()
      j = j+1
      local temp_calcul = (math.sin(j)*32)+32
      element_card[0]:set_color_modulation({160+temp_calcul,230-temp_calcul,255-temp_calcul})
      element_card[1]:set_color_modulation({temp_calcul,65+temp_calcul,125+temp_calcul})
      if sprite:get_animation() == "spell" then
        return true
      end
    end)
    sol.timer.start(enemy, (400-(life_difficulty_calcul*200))*var_2, function()
      sol.audio.play_sound(sound_list[0])
      local x_temp, y_temp, layer_temp = hero:get_position()
      i = i+1
      spawn_card(x_temp, y_temp, layer_temp, 0, 4, 0)
      if i < 5 then
        return true
      else
        for i = 0, 1 do
          element_card[i]:set_opacity(0)
        end
        reset_attack_reaction()
        sprite:set_animation("protect")
        sol.timer.start(enemy, 1000-(life_difficulty_calcul*1500), function()
          enemy:restart()
        end)
      end
    end)
  elseif state >= 6 and state <= 9 then -- card target hero
    sol.audio.play_sound(sound_list[7])
    enemy:set_can_attack(true)
    reset_attack_reaction()
    state = 1
    sprite:set_animation("flying")
    local i = 0
    sol.timer.start(enemy, (50-(life_difficulty_calcul*45))*var_2, function()
      i = i+1
      sol.audio.play_sound(sound_list[3])
      local x_temp, y_temp = hero:get_position()
      spawn_card(x, y, layer, 3, 1, sol.main.get_angle(x, y, x_temp, y_temp)*(180/math.pi))
      if i < 4 then
        return true
      else
        enemy:restart()
      end
    end)
  elseif state >= 10 then --only tp
    disable_attack_reaction()
    enemy:set_can_attack(false)
    state = 1
    sprite:set_animation("stopped")
    sol.timer.start(enemy, 100, function()
      enemy:restart()
    end)
  elseif state == -1 then -- desesperate move
    for i = 0, 1 do
      element_card[i]:set_opacity(0)
    end
    frame = 0
    enemy:set_can_attack(false)
    disable_attack_reaction()
    local i = 0
    enemy:set_position(first_x_spawn, first_y_spawn, first_layer_spawn)
    x, y, layer = enemy:get_position()
    sol.timer.start(enemy, (5-(life_difficulty_calcul*4))*math.min(var_2,2), function()
      i = i+0.05
      sprite:set_scale(1-i, 1+i)
      shadow_spr:set_opacity(255-(i*255))
      if i < 1 then
        return true
      else
        sprite:set_opacity(0)
        shadow_spr:set_opacity(0)
        sprite:set_scale(1, 1)
        sol.timer.start(enemy, 400, function()
          sol.audio.play_sound(sound_list[0])
          spawn_card(x, y, layer, 3, 1, frame)
          if frame < 1000 then
            return true
          end
        end)
        sol.timer.start(enemy, 200, function()
          sol.audio.play_sound(sound_list[3])
          local x_temp, y_temp = hero:get_position()
          spawn_card(x, y, layer, 3, 2, sol.main.get_angle(x, y, x_temp, y_temp)*(180/math.pi))
          if frame < 1000 then
            return true
          end
        end)
        sol.timer.start(enemy, 300, function()
          local x_temp, y_temp, layer_temp = hero:get_position()
          spawn_card(x_temp, y_temp, layer_temp, 0, 4, 0)
          if frame < 1000 then
            return true
          end
        end)
        sol.timer.start(enemy, 20, function()
          frame = frame+2
          if frame < 1000 then
            return true
          else
            state = 2
            enemy:restart()
          end
        end)

      end
    end)
  elseif not state == -2 then
    state = 1
    enemy:restart()
  end
end

local desesperate_move = false

function enemy:on_hurt()
  sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/hurt_"..math.random(1,3))
end

function enemy:on_dying()
  if desesperate_move then
    sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/dying")
    sol.audio.play_sound("mask_break_1")
    sol.audio.play_music("none")
    map:get_entity("end_battle"):set_enabled(true)
    enemy:set_enabled(false)
  else
    sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/desesperate_move")
    game:start_dialog(id_dialog_2, function()
      desesperate_move = true
      disable_attack_reaction()
      state = -1
      enemy:set_life(1)
      var_2 = 6
      enemy:restart()
    end)
  end
  sol.timer.stop_all(enemy)
  movement:stop()
  map:remove_entities("projo")
end

function enemy:on_dead()
  enemy:set_enabled(false)
end

function enemy:on_pre_draw(camera)
  shadow_spr:set_animation(sprite:get_animation())
  shadow_spr:set_frame(sprite:get_frame())
end
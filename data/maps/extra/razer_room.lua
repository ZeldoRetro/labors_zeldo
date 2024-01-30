-- Lua script of map extra/razer_room.

local map = ...
local game = map:get_game()

  --Modèle LINK
  local hero = map:get_hero()
  hero:set_tunic_sprite_id("hero/tunic1")

  game:set_max_life(12*4)
  game:set_life(game:get_max_life())
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  game:get_item("equipment/tunic"):set_variant(1)
  game:get_item("equipment/sword"):set_variant(3)
  game:get_item("equipment/shield"):set_variant(2)

  game:set_value("force",3)
  game:set_value("defense",2)

if not game:get_value("razer_defeated") then

 -- Liste des Musiques

 local begin_dialog_music = "razer_intro"
 local battle_music = "razer_boss"

 -- Liste des effets sonores

 local thunder_sound = "npc/razdarac_explosion"
 local boss_sound_1 = "npc/razer/snd02"
 local boss_sound_2 = "npc/razer/snd03"
 local boss_sound_3 = "npc/razer/snd04"
 local boss_sound_4 = "npc/razer/snd07"
 local boss_hurt_sound = "enemy_hurt"
 local projectile_spawn = "boss_fireball"
 local projectile_destroy = "fire"

 -- Liste des ID des dialogues

 local id_dialogue_1 = "_razer.1"
 local id_dialogue_2 = "_razer.2"

 -- Liste Stat du boss

 local damage_projectile_boss = 32
 local damage_boss = 8
 local pv_boss = 12


 -- Ici c'est la partie plus "systeme" de la salle et du boss. Le boss est directement geree par la map elle-meme.


 local light_screen
 light_screen = sol.surface.create(320, 240)
 light_screen:fill_color({255, 255, 255, 255})
 light_screen:fade_out(0)
 local black_screen
 black_screen = sol.surface.create(320, 240)
 black_screen:fill_color({0, 0, 0, 55})
 black_screen:fade_out(0)

 local corridor_mode = 1

 function map:on_started()

  map:create_npc({
    name = "dark_link",
    layer = 0,
    x = 0,
    y = 0,
    direction = 0,
    subtype = 0,
    sprite = hero:get_sprite():get_animation_set(),
  })
  dark_link:get_sprite():set_color_modulation({25,25,25,255})
  dark_link:create_sprite(hero:get_sprite("shield"):get_animation_set(), "shield")
  dark_link:create_sprite(hero:get_sprite("sword"):get_animation_set(), "sword")
  dark_link:create_sprite("extra/razer", "razer")
  dark_link:get_sprite("razer"):set_opacity(0)
 end

 function map:on_update()
  if corridor_mode == 1 or corridor_mode == 2 then
   local x, y = hero:get_position()
   local direction = hero:get_direction()
   if corridor_mode == 1 then
    if direction == 1 then
      direction = 3
      dark_link:get_sprite():set_scale(-1, 1)
      dark_link:get_sprite("shield"):set_scale(-1, 1)
      dark_link:get_sprite("sword"):set_scale(-1, 1)
    elseif direction == 3 then
      direction = 1
      dark_link:get_sprite():set_scale(-1, 1)
      dark_link:get_sprite("shield"):set_scale(-1, 1)
      dark_link:get_sprite("sword"):set_scale(-1, 1)
    else
      dark_link:get_sprite():set_scale(1, 1)
      dark_link:get_sprite("shield"):set_scale(1, 1)
      dark_link:get_sprite("sword"):set_scale(1, 1)
    end
    dark_link:set_position(x, -y+260)
    dark_link:get_sprite():set_animation(hero:get_sprite():get_animation())
    dark_link:get_sprite():set_frame(hero:get_sprite():get_frame())
    dark_link:get_sprite():set_direction(direction)
    dark_link:get_sprite("shield"):set_animation(hero:get_sprite("shield"):get_animation())
    dark_link:get_sprite("shield"):set_frame(hero:get_sprite("shield"):get_frame())
    dark_link:get_sprite("shield"):set_direction(direction)
    dark_link:get_sprite("sword"):set_animation(hero:get_sprite("sword"):get_animation())
    dark_link:get_sprite("sword"):set_frame(hero:get_sprite("sword"):get_frame())
    dark_link:get_sprite("sword"):set_direction(direction)
    if hero:get_sprite():get_animation() == "stopped" or hero:get_sprite():get_animation() == "walking" or  hero:get_sprite():get_animation() == "stopped_with_shield" or hero:get_sprite():get_animation() == "walking_with_shield" then
      dark_link:get_sprite("sword"):set_opacity(0)
    else
      dark_link:get_sprite("sword"):set_opacity(255)
    end
   elseif corridor_mode == 2 then
    if direction == 1 then
      direction = 3
    elseif direction == 3 then
      direction = 1
    end
    dark_link:set_position(x, -y+260)
    if (dark_link:get_sprite("razer"):get_animation() == "walking") and (hero:get_sprite():get_animation() == "stopped" or hero:get_sprite():get_animation() == "stopped_with_shield") then
      dark_link:get_sprite("razer"):set_animation("stopped")
    elseif (dark_link:get_sprite("razer"):get_animation() == "stopped") and (hero:get_sprite():get_animation() == "walking" or hero:get_sprite():get_animation() == "walking_with_shield") then
      dark_link:get_sprite("razer"):set_animation("walking")
    end
    dark_link:get_sprite("razer"):set_direction(direction)
    
   end
  end
 end

 function map:on_opening_transition_finished()

 end

 function map:loop_mirror_attack()
  sol.timer.start(map, 400, function()
    if pv_boss <= 0 then
      return
    end
    if not map:has_entities("mirror_entity_shadowboss") then
      local random_choose_position = math.random(1,3)
      if random_choose_position == 1 then
        map:generate_shadowboss(razer_spawner_1:get_position())
      elseif random_choose_position == 2 then
        map:generate_shadowboss(razer_spawner_2:get_position())
      else
        map:generate_shadowboss(razer_spawner_3:get_position())
      end
    end
    return true
  end)
 end

 function map:begin_intro_battle()
  corridor_mode = 3
  game:set_pause_allowed(false)
  hero:freeze()
  dark_link:get_sprite("razer"):set_direction(3)
  sol.audio.play_music(begin_dialog_music)
  dark_link:get_sprite("razer"):fade_in(30, function()
    game:start_dialog(id_dialogue_1, function()
      sol.timer.start(map, 400, function()
        sol.audio.play_sound(boss_sound_4)
        game:start_dialog(id_dialogue_2, function()
          sol.audio.stop_music()
          dark_link:get_sprite("razer"):set_animation("hurt")
          sol.audio.play_sound(boss_sound_2)
          dark_link:get_sprite("razer"):fade_out(10, function()
            sol.audio.play_music(battle_music)
            game:set_pause_allowed(true)
            hero:unfreeze()
            map:loop_mirror_attack()
            dark_link:remove()
          end)
        end)
      end)
    end)
  end)
 end

 function sensor_loop_begin:on_activated()
  sol.audio.stop_music()
  light_screen:fade_out(30)
  black_screen:fade_in(60)
  sol.audio.play_sound(thunder_sound)
  corridor_mode = 2
  dark_link:remove_sprite()
  dark_link:remove_sprite(dark_link:get_sprite("shield"))
  dark_link:remove_sprite(dark_link:get_sprite("sword"))
  dark_link:get_sprite("razer"):set_opacity(255)
  sol.timer.start(map, 4000, function()
    dark_link:get_sprite("razer"):fade_out(35, function()
      sol.timer.start(map, 3000, function()
        map:begin_intro_battle()
      end)
    end)
  end)
  sensor_loop_begin:remove()
 end

 function sensor_loop_1:on_activated()
  if corridor_mode >= 2 then
    local x, y = hero:get_position()
    hero:set_position(x+168, y)
    for entity in map:get_entities("mirror_entity") do
      local x_entity, y_entity = entity:get_position()
      entity:set_position(x_entity+168, y_entity)
    end
  end
 end

 function sensor_loop_2:on_activated()
  if corridor_mode >= 2 then
    local x, y = hero:get_position()
    hero:set_position(x-168, y)
    for entity in map:get_entities("mirror_entity") do
      local x_entity, y_entity = entity:get_position()
      entity:set_position(x_entity-168, y_entity)
    end
  end
 end

 function map:generate_bossprojectile(x, y)
  sol.audio.play_sound(projectile_spawn)
  local boss_projectile = map:create_custom_entity{
      name = "mirror_entity",
      direction = 0,
      x = x,
      y = y,
      layer = 1,
      width = 8,
      height = 8,
      sprite = "extra/razer",
    }
  boss_projectile:get_sprite():set_animation("projectile")
  sol.timer.start(boss_projectile, 4000, function()
    boss_projectile:get_sprite():fade_out(10, function()
      boss_projectile:remove()
    end)
  end)
  boss_projectile:set_origin(4,4)
  local movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(256)
  movement:start(boss_projectile)
  function boss_projectile:on_update()
    if boss_projectile:get_ground_below() == "wall" then
      sol.audio.play_sound(projectile_destroy)
      boss_projectile:clear_collision_tests()
      boss_projectile:remove()
      return
    end
  end
  boss_projectile:add_collision_test("sprite", function(entity, other, entity_sprite, other_sprite)
    if other_sprite == hero:get_sprite("sword") then
      sol.audio.play_sound(projectile_destroy)
      boss_projectile:clear_collision_tests()
      boss_projectile:remove()
      return
    end
    if other:get_type() == "hero" then
      boss_projectile:clear_collision_tests()
      other:start_hurt(boss_projectile, damage_projectile_boss)
      boss_projectile:remove()
      return
    end
  end)
 end

 function map:battle_end()
  sol.audio.stop_music()
  game:set_value("razer_defeated", true)
  sensor_loop_1:remove()
  sensor_loop_2:remove()
 end

 function map:generate_shadowboss(x, y)
  sol.audio.play_sound(boss_sound_2)
  local boss_shadow = map:create_custom_entity{
      name = "mirror_entity_shadowboss",
      direction = 0,
      x = x+4,
      y = y,
      layer = 1,
      width = 16,
      height = 16,
      sprite = "extra/razer",
    }
  boss_shadow:set_origin(8,13)
  boss_shadow:get_sprite():set_direction(3)
  boss_shadow:get_sprite():set_animation("appear", function()
    boss_shadow:get_sprite():set_animation("stopped")
  end)
  local movement = sol.movement.create("straight")
  movement:set_angle(3 * math.pi / 2)
  movement:set_speed(48)
  movement:set_max_distance(24)
  movement:set_ignore_obstacles(true)
  movement:start(boss_shadow, function()
    sol.timer.start(boss_shadow, 50, function()
     local function razer_boss_ai_launch(reentity, x, y)
      local set_shadow_invincible = false
      reentity:get_sprite():set_animation("walking")
      local x_hero, y_hero = hero:get_position()
      local movement = sol.movement.create("straight")
      if x <= x_hero then
        movement:set_angle(0)
        movement:set_speed(hero:get_walking_speed())
        movement:set_ignore_obstacles(true)
        reentity:get_sprite():set_direction(0)
      else
        movement:set_angle(math.pi)
        movement:set_speed(hero:get_walking_speed())
        movement:set_ignore_obstacles(true)
        reentity:get_sprite():set_direction(2)
      end
      movement:start(reentity)
      sol.timer.start(reentity, 2500, function()
        reentity:get_sprite():set_animation("stopped")
        movement:stop()
        sol.timer.stop_all(reentity)
        set_shadow_invincible = true
        sol.timer.start(reentity, 900, function()
          reentity:get_sprite():set_animation("attack")
          map:generate_bossprojectile(reentity:get_position())
          sol.timer.start(reentity, 500, function()
            local x_self, y_self = reentity:get_position()
            razer_boss_ai_launch(reentity, x_self, y_self)
          end)
        end)
      end)
        reentity:add_collision_test("sprite", function(entity, other, entity_sprite, other_sprite)
         if not set_shadow_invincible then
          if other_sprite == hero:get_sprite("sword") then
           hero:set_animation("stopped")
           hero:unfreeze()
           pv_boss = pv_boss-1
           if pv_boss <= 0 then
            sol.audio.play_sound(boss_sound_1)
            reentity:get_sprite():set_animation("hurt")
            reentity:get_sprite():fade_out(10, function()
              reentity:remove()
              map:battle_end()
            end)
            return
           else
            movement:stop()
            sol.timer.stop_all(reentity)
            sol.audio.play_sound(boss_sound_3)
            sol.audio.play_sound(boss_hurt_sound)
            set_shadow_invincible = true
            reentity:get_sprite():set_animation("hurt")
            reentity:get_sprite():fade_out(10, function()
              reentity:remove()
            end)
            return
           end
          end
          if other:get_type() == "hero" then
            movement:stop()
            sol.timer.stop_all(reentity)
            set_shadow_invincible = true
            other:start_hurt(reentity, damage_boss)
            sol.timer.start(reentity, 900, function()
              local x_self, y_self = reentity:get_position()
              razer_boss_ai_launch(reentity, x_self, y_self)
            end)
            return
          end
         end
        end)
      
     end
     razer_boss_ai_launch(boss_shadow, x, y)
    end)
  end)
 end

 function map:on_draw(dst_surface)
	light_screen:draw(dst_surface)
	black_screen:draw(dst_surface)
 end

end
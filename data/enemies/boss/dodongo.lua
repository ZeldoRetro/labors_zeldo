local enemy = ...
--local behavior = require("enemies/library/towards_hero")

-- Dodongo: Dinosaur enemy that is susceptible only to bombs.

-- pour que le Dodongo subisse des degats, il doit lancer la function "enemy:gobble_bomb_start()" pendant qu'il est dans l'animation "open_mouth", cette function lance simplement une animation qui se termine par un dégat puis retour sur les déplacements normaux. La version actuel de cet ennemi ne permet pas de détecter la collision avec la bombe build-in du moteur et nécessite d'ajouter une custom_entities de la bombe. Le script de la Custom Bomb inclue dans le zip avec les dossiers du dodongo contient le bout de script qui vérifie si elle-même est en contact avec le sprite dodongo_head de l'ennemi Dodongo. Evitez d'inclure tout l'entièreté des fichiers de la custom_bomb tout de suite, vérifiez si vous n'en possédez pas déjà un dans votre quête, et copiez-collez le bout de script de la custom bomb permettant la détection entre la bombe et les hitboxs précis du dodongo dans votre custom bomb actuel. La bombe custom inclue dans le zip est repris de Zelda A Link to the Dream, il n'a pas été programmé par moi. J'ai seulement ajouté le bout de script permettant la collision entre bombe et dodongo (avec l'aide de Christopho et Zeldo sur le Discord, merci à eux).



-- Emplacement des fichiers necessaires :
-- "data/enemies/dungeons/dodongo.lua"
-- "data/entities/lib/carriable.lua"
-- "data/entities/bomb.lua"
-- "data/entities/explosion.lua"
-- "data/scripts/states/carrying.lua"
-- "data/sprites/enemies/dungeons/dodongo.dat"
-- "data/sprites/enemies/dungeons/dodongo.png"
-- "data/sprites/enemies/dungeons/dodongo_head.dat"
-- "data/sprites/enemies/dungeons/dodongo_head.png"
-- "data/sprites/enemies/dungeons/dodongo_fire.dat"
-- "data/sprites/enemies/dungeons/dodongo_fire.png"


local normal_speed = 32
local timer_mouth = 2500
local main_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local head_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head")
local fire_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_fire")
local movement
local sound_swallow_link
local sound_biting_link
local sound_link_escape
local sound_dodongo_fire
local sound_dodongo_explode
local sound_dodongo_openmouth
local sound_dodongo_walk
local devours_to_the_last_life

function enemy:on_created()

  --if the Dodongo devour the hero to the before last heart
  devours_to_the_last_life = false

  --classic stat
  self:set_life(6)
  self:set_damage(4)
  self:set_size(64, 48)
  self:set_origin(32, 40)
  self:set_hurt_style("normal")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_obstacle_behavior("normal")
  self:set_attacking_collision_mode("sprite")
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_hammer_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence_sprite(fire_sprite, "sword", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "thrown_item", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "explosion", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "arrow", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "hookshot", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "boomerang", "ignored")
  self:set_attack_consequence_sprite(fire_sprite, "fire", "ignored")


-- MOVEMENT

  function enemy:on_restarted()
    enemy:go_random()
  end

  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    main_sprite:set_direction(direction4)
    head_sprite:set_direction(direction4)
    fire_sprite:set_direction(direction4)
  end

  function enemy:go_random()
    main_sprite:set_animation("walking")
    movement = sol.movement.create("random_path")
    movement:set_speed(normal_speed)
    movement:start(enemy)
    sol.timer.stop_all(self)
    sol.timer.start(self, 4000, function() enemy:prepare_attack() end)
    sol.timer.start(self, 330, function()
      enemy:check_player_enemy_same_area()    
    end)
  end

  function enemy:prepare_attack()
     if main_sprite:get_animation() == "walking" then
        movement:stop()
        main_sprite:set_animation("open_mouth")
        sol.audio.play_sound("dinosaur")
        sol.timer.start(self, timer_mouth, function() enemy:launch_attack() end)
     else
        enemy:go_random()
     end
  end

  function enemy:launch_attack()
     if main_sprite:get_animation() == "open_mouth" then
        movement:stop()
        main_sprite:set_animation("flame_attack")
        sol.audio.play_sound("fire")
        sol.timer.start(self, 2000, function() enemy:go_random() end)
     else
        enemy:go_random()
     end
  end

  function enemy:gobble_bomb_start()
     if main_sprite:get_animation() == "open_mouth" then
        sol.timer.stop_all(self)
        main_sprite:set_animation("gobble_bomb", function()
          sol.audio.play_sound("explosion")
          main_sprite:set_animation("gobble_bomb_explode", function()
            enemy:hurt(1)
          end)
        end)
     else
     enemy:go_random()
     end
  end

  function enemy:devours_to_the_last_command()
    devours_to_the_last_life = true
  end

-- check if player and enemy in same region
  function enemy:check_player_enemy_same_area()
    local hero = enemy:get_map():get_hero()
      if not enemy:is_in_same_region(hero) or enemy:get_distance(hero) >= 200 then
        movement:stop()
        enemy:waiting_player()
      end
  end

  function enemy:waiting_player()
    sol.timer.stop_all(self)
    local hero = enemy:get_map():get_hero()
    main_sprite:set_animation("idle")
    sol.timer.start(self, 200, function()
      if enemy:is_in_same_region(hero) and enemy:get_distance(hero) < 200 then
        sol.timer.stop_all(self)
        sol.timer.start(self, 1500, function() enemy:go_random() end)
      end
      return true
    end)
  end

end

function enemy:on_hurt()
  normal_speed = normal_speed + 4
  timer_mouth = timer_mouth - 200
end





-- ANIMATION AND COLLISION

-- set same animation id to head_sprite when main_sprite is updated
function main_sprite:on_animation_changed(animation)
  head_sprite:set_animation(main_sprite:get_animation())
  fire_sprite:set_animation(main_sprite:get_animation())
end

-- you cannot overload functions on_attacking_hero
-- pass enough parameters to a single function instead
function enemy:on_attacking_hero(hero, sprite)


-- if mouth sprite appeared and collision with player, play this animation
 if sprite == head_sprite then

  local game = enemy:get_game()
  if enemy:get_sprite():get_animation() == "open_mouth" then
   hero:set_invincible(true)
   sol.timer.stop_all(self)
    local number_time_calcul_1
    local number_time_calcul_2
    if devours_to_the_last_life == true then
      number_time_calcul_1 = 540*(game:get_life()-2) --630
      number_time_calcul_2 = game:get_life()-3 --630
    else
      number_time_calcul_1 = 540*4 --630
      number_time_calcul_2 = 3 --630
    end

   enemy:get_sprite():set_animation("gobble_link_bitten_90ms")
   sol.timer.start(hero, 180, function()
    hero:freeze()
    hero:set_visible(false)
    sol.timer.start(hero, 270, function()
    game:remove_life(1)
    end)
-- timer of multiple damage
    local num_calls = 0
    sol.timer.start(hero, 540, function() --500
      sol.timer.start(hero, 270, function()
      game:remove_life(1)
      end)
      num_calls = num_calls + 1
      return num_calls < number_time_calcul_2
    end)



-- Animation of Dodongo and reactivate Hero movement
    sol.timer.start(hero, number_time_calcul_1, function() --1970
       enemy:get_sprite():set_animation("gobble_link_escape", function()
          enemy:go_random()
       end)
       sol.timer.start(hero, 100, function()
         sol.timer.start(hero, 30, function()
          hero:unfreeze()
          hero:set_visible(true)
          hero:set_invincible(false)
          hero:start_hurt(enemy, 1)
         end)
       end)
    end)
   end)
  end

 end
  -- if the body sprite touch player
 if sprite == main_sprite then
   hero:start_hurt(enemy, enemy:get_damage())
 end
  -- collision with fire
 if sprite == fire_sprite then
   hero:start_hurt(4)
 end

end
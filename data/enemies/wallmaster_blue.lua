-- Wallmaster blue : Just moves randomly and grab hero

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(3)
  enemy:set_damage(0)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()

  movement = sol.movement.create("path_finding")
  movement:set_target(hero)
  movement:set_speed(32)
  movement:start(enemy)
end

function enemy:on_attacking_hero()
  hero:freeze()
  hero:set_invincible(true, 10)
    sol.timer.start(hero, 10, function()
    sol.audio.play_sound("hero_hurt")
    hero:set_animation("hurt")
    hero:teleport(game:get_starting_location())

    -- When teleporting to the same room, restart the hand while the screen is black.
    sol.timer.start(game, 600, function()
      if enemy:exists() then
        enemy:restart()
      end
    end)
  end)
end
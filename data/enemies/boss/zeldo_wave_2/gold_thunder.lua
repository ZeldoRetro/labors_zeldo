-- Lua script of enemy bosses/zeldo/gold_thunder.
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()
  enemy:set_invincible()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_dying_sprite_id("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage( tonumber(enemy:get_property("damage")) ~= nil and tonumber(enemy:get_property("damage")) or 4 )
  enemy:set_can_attack(false)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_obstacle_behavior("flying")
end

function enemy:on_restarted()
  local i = 0
  sol.audio.play_sound("lightning_target")
  sol.timer.start(enemy, 50, function()
    i = i+1
    sprite:set_scale(1.4-(i/8), 1.2-(i/8))
    sprite:set_color_modulation({255,255-(i*25),255-(i*25),255})
    if i >= 10 then
      sol.audio.play_sound("lightning_hit")
      i = 0
      sprite:set_animation("stopped")
      sprite:set_xy(0,-32)
      sprite:set_scale(1, 0)
      sprite:set_color_modulation({255,255,255,255})
      sol.timer.start(enemy, 50, function()
        i = i+5
        sprite:set_scale(1+(i/35), i/20)
        if i >= 20 then
          i = 255
          sol.timer.start(enemy, 50, function()
            i = math.max(i-50, 0)
            sprite:set_scale(1+((255-i)/25), i/255)
            sprite:set_xy(0, -32+((255-i)/8) )
            sprite:set_opacity(i)
            if i == 0 then
              enemy:remove()
            else
              return true
            end
          end)
        else
          if i == 15 then
            enemy:set_can_attack(true)
          end
          return true
        end
      end)
    else
      return true
    end
  end)
end
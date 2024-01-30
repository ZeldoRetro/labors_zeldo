-- Magic Boomerang shot by Bokoblins/Goriyas

local enemy = ...

local x,y = enemy:get_position()

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_minimum_shield_needed(2) -- Hylian shield.
end

function enemy:on_obstacle_reached()
  local movement2 = sol.movement.create("target")
  movement2:set_target(x,y)
  movement2:set_speed(240)
  movement2:set_smooth(false)
  movement2:start(enemy,function() enemy:remove() end)
  sol.timer.start(enemy,1000,function() enemy:remove() end)
end

function enemy:go(direction4)

  local movement = sol.movement.create("target")
  sol.timer.start(enemy,150,function() sol.audio.play_sound("boomerang") return true end)
  movement:set_speed(240)
  movement:set_target(enemy:get_map():get_hero())
  movement:set_smooth(false)
  sol.timer.start(enemy, 10, function()
    local movement2 = sol.movement.create("target")
    movement2:set_target(x,y)
    movement2:set_speed(240)
    movement2:set_smooth(false)
    movement:start(enemy,function()
      movement2:start(enemy,function() enemy:remove() end)
    end)
  end)

  enemy:get_sprite():set_direction(direction4)

  sol.timer.start(enemy,3000,function() enemy:remove() end)
end
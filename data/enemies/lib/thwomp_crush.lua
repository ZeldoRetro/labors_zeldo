local behavior = {}

-- Behavior of an enemy that falls to the ground if the hero is under it, then goes back to it's initial position.
-- The enemy has only one sprite.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/towards_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 1,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 32,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   ignore_obstacles = false,
--   obstacle_behavior = "flying",
--   detection_distance = 100,
--   movement_create = function()
--     local m = sol.movement.create("random_path")
--     return m
--   end
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.
local audio_manager = require("scripts/audio_manager")
function behavior:create(enemy, properties)

  local falling = false
  local returning_home = false
  local home_x, home_y
  local platform
  local platform_dx, platform_dy
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 100
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = false
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = true
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.crash_sound == nil then
    properties.crash_sound = "items/bomb_drop"
  end
  if properties.is_walkable == nil then
    properties.is_walkable = false
  end
  if properties.outer_detection_range == nil then
    properties.outer_detection_range=0
  end
  properties.movement_create = function()
    local m = sol.movement.create("straight")
    return m
  end

  enemy.home_x, enemy.home_y=enemy:get_position()
  enemy:set_damage(properties.damage)
  enemy:create_sprite(properties.sprite)
  enemy:set_hurt_style(properties.hurt_style)
  enemy:set_pushed_back_when_hurt(properties.pushed_when_hurt)
  enemy:set_push_hero_on_sword(properties.push_hero_on_sword)
  enemy:set_obstacle_behavior(properties.obstacle_behavior)
  local w,h =enemy:get_sprite():get_size()
  enemy:set_size(w,h)
  enemy:set_origin(w/2, h-3)

  enemy:set_invincible()
  enemy:get_sprite():set_animation("normal")


  if properties.is_walkable then --Create a platform on it's top
    local x,y,w,h=enemy:get_bounding_box()
    platform = enemy:get_map():create_custom_entity({
        x=x,
        y=y,
        layer= enemy:get_layer(),
        direction = 3,
        width = w,
        height= 8,
        model = "platform_thwomp",
      })
    platform:set_size(w,1)
    platform:set_origin(0,0)
    platform:set_enabled(enemy:is_enabled())
  end


  function enemy:on_position_changed()
    if platform then
      x, y=enemy:get_bounding_box()
      platform:set_position(x, y)
    end
  end

  local function look_at_hero()
    local hero = enemy:get_map():get_entity("hero")
    local angle = enemy:get_angle(hero)
    local sprite = enemy:get_sprite()
    local n = sprite:get_num_directions()
    local dir_arc = 2*math.pi/n
    local index = math.floor((angle+dir_arc/2)*n/(2*math.pi))%n
    sprite:set_direction(index)
    return true
  end

  function enemy:on_obstacle_reached(movement)
    if falling and not sound_played then
      sound_played = true
      audio_manager:play_sound(properties.crash_sound)

      sol.timer.stop_all(enemy)
      sol.timer.start(enemy, 1000, function()
          local sprite = enemy:get_sprite()
          enemy:go_home()
        end)      
    end
  end

  function enemy:check_hero()
    look_at_hero()
    local hero = enemy:get_map():get_entity("hero")
    local x, _, w = enemy:get_bounding_box()
    local hx = hero:get_position()
    local hero_is_under_me = hx>=x-properties.outer_detection_range and
    hx<=x+w+properties.outer_detection_range and
    enemy:is_in_same_region(hero)
    if hero_is_under_me and not falling and not returning_home then
      enemy:fall()
    end
    sol.timer.stop_all(enemy)
    sol.timer.start(enemy, 100, function() enemy:check_hero() end)
  end

  function enemy:on_restarted()
    if falling then
      enemy:fall()
    else
      enemy.go_home()
    end
  end

  function enemy:fall()
    --print("Crushing time!")
    falling=true
    audio_manager:play_sound("hero/throw")
    enemy:get_sprite():set_animation("falling")    
    local m = sol.movement.create("straight")
    m:set_speed(properties.faster_speed)
    m:set_angle(3*math.pi/2)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(enemy)
  end

  function enemy:on_removed()
    if platform then
      platform:remove()
    end
  end

  function enemy:on_disbled()
    if platform then
      platform:set_enabled(false)
    end    
  end

  function enemy:on_enabled()
    if platform then
      platform:set_enabled(true)
    end  
  end

  function enemy:go_home()
    falling = false
    sound_played = false
    returning_home=true 

    local m = sol.movement.create("target")
    m:set_speed(properties.normal_speed)
    m:set_target(enemy.home_x, enemy.home_y)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(enemy, function()
        enemy:get_sprite():set_animation("normal")
        returning_home=false
        enemy:check_hero()
      end)
  end
end

return behavior


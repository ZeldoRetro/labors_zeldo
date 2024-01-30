-- Stone Arrghus

local enemy = ...
local game = enemy:get_game()

local movement
local stunned = false

local max_minis = 0

local function invoke_minis()
      arrghusmini_breed = "boss/arrghus_baby"
      i = enemy:get_map():get_entities_count("arrghusmini_")
      sol.timer.start(enemy:get_map(),300,function()
        enemy:create_enemy({
        	name = "arrghusmini_",
        	breed = arrghusmini_breed,
          treasure_name = "pickable/random_bombs"
        })

        i = i + 1
        return i < max_minis
      end)
end

function enemy:on_created()

  enemy:set_life(16)
  enemy:set_damage(8)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_obstacle_behavior("flying")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)

end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  movement = sol.movement.create("path_finding")
  movement:set_speed(64)
  movement:start(enemy)

  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_attack_consequence("thrown_item", "protected")
  enemy:set_arrow_reaction("protected")
  enemy:set_hookshot_reaction("protected")
  enemy:set_hammer_reaction("protected")
  enemy:set_fire_reaction("protected")
  enemy:set_ice_reaction("protected")
  enemy:set_attack_consequence("explosion", "custom")
end

function enemy:on_custom_attack_received(attack, sprite)
  local hero = enemy:get_map():get_hero()
  if attack == "explosion" then
    stunned = true
    movement:stop()
    enemy:get_sprite():set_animation("immobilized")

    enemy:set_attack_consequence("sword", 1)
    enemy:set_arrow_reaction(2)
    enemy:set_hammer_reaction(4)
    enemy:set_attack_consequence("explosion", "ignored")

    sol.timer.start(5000, function ()
      stunned = false
      enemy:restart()
    end)
  end
end

function enemy:on_hurt()

  if enemy:get_life() <= 0 then
    self:get_map():remove_entities("arrghusmini_")
  else
    if self:get_map():get_entities_count("arrghusmini_") <= 6 then invoke_minis() end
    max_minis = max_minis + 1
  end

end
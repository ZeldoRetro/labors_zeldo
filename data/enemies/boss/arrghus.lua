-- Arrghus boss.

local enemy = ...
local i = 0

local function invoke_baris()
      if enemy:get_life() > 12 then bari_breed = "bari_green_circle"
      elseif enemy:get_life() <= 12 and enemy:get_life() > 6 then bari_breed = "bari_blue_circle"
      elseif enemy:get_life() <= 6 then bari_breed = "bari_red_circle" end
      i = enemy:get_map():get_entities_count("bari_")
      sol.timer.start(enemy:get_map(),300,function()
        enemy:create_enemy({
        	name = "bari_",
        	breed = bari_breed,
        })

        i = i + 1
        return i < 6
      end)
end

function enemy:on_created()

  enemy:set_life(24)
  enemy:set_damage(4)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_obstacle_behavior("flying")
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_attack_consequence("explosion", 1)
  enemy:set_attack_consequence("thrown_item", 1)
  enemy:set_arrow_reaction(1)
  enemy:set_hookshot_reaction("protected")
  enemy:set_fire_reaction(2)
  enemy:set_ice_reaction(2)
  enemy:set_hammer_reaction(1)

end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(16)
  movement:start(enemy)

end

function enemy:on_enabled()
  invoke_baris()
end

function enemy:on_hurt()
  if self:get_map():get_entities_count("bari_") <= 3 then invoke_baris() end
end
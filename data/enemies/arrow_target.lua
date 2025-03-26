--Archery Minigame Target

local enemy = ...
local game = enemy:get_game()
local map = game:get_map()

local score

function enemy:on_created()

  self:set_life(1)
  self:set_invincible()
  self:set_optimization_distance(0)  -- This is done manually by the map.
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
  self:set_arrow_reaction("custom")
end

function enemy:on_restarted()

  local movement = sol.movement.create("straight")

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  local direction4 = enemy:get_sprite():get_direction()
  local angle = direction4 * math.pi / 2
  movement:set_speed(56)
  movement:set_angle(angle)

  movement:set_max_distance(304)

  movement:start(self, function()
    enemy:remove()
  end)

  -- debug TODO
  movement:set_ignore_obstacles(true)
end

function enemy:on_custom_attack_received()
  sol.timer.start(enemy,50,function() sol.audio.play_sound("piece_of_heart") end)
  score = game:get_value("ahf_archery_1_score")
  game:set_value("ahf_archery_1_score",score + 1)
  map:set_entities_enabled("archery_score_",false)
  map:set_entities_enabled("archery_score_"..game:get_value("ahf_archery_1_score"),true)
  if game:get_value("ahf_archery_1_score") >= 10 then map:set_entities_enabled("archery_score_perfect") end
end

--Le dommage de l'ennemi sera de 4, quelle que soit la défense
function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(3)
  hero:start_hurt(enemy, 1)
end
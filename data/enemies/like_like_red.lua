-- Lua script of enemy dungeons/like_like.
local enemy = ...

local shield_save_id = "possession_shield"
local shield_item_id = "equipment/shield"

-- Tous les items a exclure pour eviter des softlock lorsque le like like devore le bouclier.
local item_to_exclude = {
  "dungeons/big_key",
  "dungeons/compass",
  "dungeons/map",
  "dungeons/small_key",
  "quest_items/heart_container",
  "quest_items/piece_of_heart",
}
-- if you want the "Gold" variant of the monster to be able to spawn. Note that if the enemy already has an assigned item such as a door key, it will never be modified to the "Gold" variant, therefore avoiding a potential softlock.
local gold_variant_spawning = false
-- the sprite ID of the star particule (you can ignore if gold_variant_spawning is "false")
local gold_particule_sprite = "entities/star"
-- The spawn probability of the “gold” variant of the entity. The higher the value, the rarer the variant will be. (you can ignore if gold_variant_spawning is "false")
local gold_spawn_probability = 2
-- The properties (ID, and Variant of the item) of the item dropped by the fire-fairy in "Gold" variant. (you can ignore if gold_variant_spawning is "false")
local gold_item_id, gold_item_variant = "consumables/rupee", 5

local treasure_name, treasure_variant, treasure_savegame = enemy:get_treasure()
local can_overide_item = true

for key, name in pairs(item_to_exclude) do
  if treasure_name == name then
    can_overide_item = false
  end
end

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local movement

local sound_enemy = {}

local main_sprite
local eating_hero_timer = 0
local eating_hero_swordhurt = false

local launch_timer_gold = false

local enemy_variant = enemy:get_property("variant")
if enemy_variant == nil then enemy_variant = "normal" end

local function choose(number_of_value, values)
  if number_of_value == 0 then return end
  local r = math.floor(math.random(1,number_of_value))
  return values[r]
end

function enemy:on_created()

  main_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(16)
  enemy:set_damage(8)

  sound_enemy[0] = "octorok"
  sound_enemy[1] = "swim"
  sound_enemy[2] = "fire"
  sound_enemy[3] = "walk_on_water"

  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 16)
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("thrown_item", "custom")
  enemy:set_attack_consequence("explosion", "custom")
  enemy:set_attack_consequence("arrow", "custom")
  enemy:set_attack_consequence("hookshot", "immobilized")
  enemy:set_attack_consequence("boomerang", "immobilized")
  enemy:set_attack_consequence("fire", "custom")

  enemy:set_attacking_collision_mode("overlapping")
end

function enemy:on_restarted()
  if (eating_hero_timer <= 0) then
    main_sprite:set_animation("walking")
    enemy:go_target()
  end
end

function enemy:sound_play(sound_id)
  local map = enemy:get_map()
  local hero = map:get_hero()
  if enemy:get_distance(hero) < 500 and enemy:is_in_same_region(hero) then
    if not map.likelike_recent_sound then
      sol.audio.play_sound(sound_id)
      map.likelike_recent_sound = true
      sol.timer.start(map, 100, function()
        map.likelike_recent_sound = nil
      end)
    end
  end
end

function enemy:go_target()
 if enemy:is_in_same_region(hero) and enemy:get_distance(hero) < 250 then
  movement = sol.movement.create("target")
  local x_t, y_t, layer_t = enemy:get_position()
  local check_layer = hero:get_layer()
  if enemy:is_in_same_region(hero) and enemy:get_distance(hero) < 100 and check_layer == layer_t then
    movement:set_target(hero)
  else
    x_t = choose(3, {x_t-16, 0, x_t+16})
    y_t = choose(3, {y_t-16, 0, y_t+16})
    movement:set_target(x_t, y_t)
  end
  movement:set_speed(32)
  movement:start(enemy)
  sol.timer.start(enemy, 300, function()
    movement:stop()
    enemy:go_target()
  end)
 else
  sol.timer.start(enemy, 10, function()
    enemy:restart()
  end)
 end
end

function enemy:eating_player()
  enemy:sound_play(sound_enemy[0])
  for sprite_name, sprite in hero:get_sprites() do
    if not (sprite_name == "sword" or sprite_name == "sword_stars") then
      sprite:set_opacity(0)
    end
  end
  main_sprite:set_animation("eating")
  eating_hero_timer = 5000
  local x, y, layer = enemy:get_position()
  sol.timer.start(hero, 10, function()
    eating_hero_timer = eating_hero_timer-1
    hero:set_position(x, y, layer)
    if (enemy:get_life() > 0) and (eating_hero_timer > 0) then
      return true
    else
      hero:start_hurt(enemy, enemy:get_damage())
      for sprite_name, sprite in hero:get_sprites() do
        if not (sprite_name == "sword" or sprite_name == "sword_stars") then
          sprite:set_opacity(255)
        end
      end
      enemy:sound_play(sound_enemy[3])
      main_sprite:set_animation("escape", function()
        enemy:restart()
      end)
    end
  end)
  

  sol.timer.start(enemy, 250, function()
    if eating_hero_timer > 0 then
      game:remove_life(1)
      enemy:sound_play(sound_enemy[1])
    end
    return eating_hero_timer > 0
  end)

    -- if hero as shield, and if the like-like can drop it
    if (game:get_value(shield_save_id) ~= nil) and (game:get_value(shield_save_id) < 3) then
      local shield_variant = game:get_ability("shield")
      game:set_ability("shield", 0)
      game:set_value(shield_save_id, nil)
      enemy:set_treasure(shield_item_id, shield_variant, nil)
      sol.timer.start(map, 5000, function()
        enemy:set_treasure(treasure_name, treasure_variant, treasure_savegame)
      end)
    end

end

function enemy:on_custom_attack_received(attack, sprite)
  local damage_total = 1
  if attack == "sword" then damage_total = 1+((game:get_ability("sword")-1)*2) end
  if attack == "arrow" then damage_total = 2+((game:get_value("possession_bow")-1)*8) end
  if attack == "boomerang" then damage_total = game:get_value("possession_boomerang") end

  if eating_hero_timer > 0 then
    sol.audio.play_sound(sound_enemy[2])
    eating_hero_timer = eating_hero_timer-1000
    main_sprite:set_direction(hero:get_direction())
    main_sprite:set_animation("struggles", function() main_sprite:set_animation("eating") end)
  else
    main_sprite:set_animation("hurt")
    sol.audio.play_sound("enemy_hurt")
    sol.timer.start(enemy, 300, function()
      main_sprite:set_animation("walking")
      enemy:remove_life(damage_total)
    end)
  end
end

function enemy:on_attacking_hero(hero, sprite)
  if (main_sprite:get_animation() == "walking") and (eating_hero_timer <= 0) then
    movement:stop()
    enemy:eating_player()
  end
end
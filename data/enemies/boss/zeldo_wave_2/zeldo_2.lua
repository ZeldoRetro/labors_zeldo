-- Zeldo enemies 2, flying and weak to bow
local enemy = ...
local map = enemy:get_map()
local game = enemy:get_game()
local hero = map:get_hero()
local shield_life_max
local shield_life
local spawn_x, spawn_y
local attack_reaction = {"sword","thrown_item","explosion","hookshot","boomerang","fire"}
local sounds = {}
local desesperate_move
local movement

function enemy:change_attacks_reaction(reaction)
  for k, v in pairs(attack_reaction) do
    enemy:set_attack_consequence(v, reaction)
  end
end

function enemy:sound_play(sound_id)
  sol.audio.play_sound(sound_id)
end

function enemy:launch_attack()
  enemy:get_sprite("bow"):set_animation("bow")
  enemy:get_sprite("bow"):set_opacity(0)
  enemy:get_sprite("bow"):set_xy( 0,0 )
  enemy:get_sprite("wing"):set_animation("wing")
  enemy:get_sprite("wing"):set_opacity(255)
  enemy:get_sprite("wing"):set_color_modulation({255,255,255,255})
  enemy:get_sprite("zeldo"):set_animation("flying")

  if movement ~= nil then movement:stop() end
  local angle_radian = -math.rad(math.random(40, 140))
  local distance = math.random(120,160)
  movement = sol.movement.create("target")
  movement:set_target( spawn_x+(math.cos(angle_radian)*distance), spawn_y+(math.sin(angle_radian)*distance) )
  movement:set_ignore_obstacles(true)
  movement:set_speed(236-enemy:get_life())
  movement:start(enemy)

  enemy.attack[math.random(0,#enemy.attack)](enemy)
end

function enemy:on_created()
  --Created
  sounds[0] = "glass_bonk" -- Shield Damaged
  sounds[1] = "glass_break" -- Shield Break
  sounds[2] = "sword_spin_attack_load" -- Charge Arrow
  sounds[3] = "bow" -- Arrow
  sounds[4] = "hero_lands" -- Boss land to ground
  sounds[5] = sol.language.get_language().."/zeldo_wave_2_voice/attack_arrows1" -- attaque flèches 1
  sounds[6] = sol.language.get_language().."/zeldo_wave_2_voice/attack_arrows1_alt" -- attaque flèches 1 ALT
  sounds[7] = sol.language.get_language().."/zeldo_wave_2_voice/attack_arrows2" -- attaque flèches 2
  sounds[8] = sol.language.get_language().."/zeldo_wave_2_voice/attack_arrows2_alt" -- attaque flèches 2 ALT
  sounds[9] = sol.language.get_language().."/zeldo_wave_2_voice/attack_thunder" -- attaque foudre
  sounds[10] = sol.language.get_language().."/zeldo_wave_2_voice/attack_thunder_alt" -- attaque foudre ALT
  sounds[11] = sol.language.get_language().."/zeldo_wave_2_voice/what" -- what
  sounds[12] = sol.language.get_language().."/zeldo_wave_2_voice/what_alt" -- what ALT
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_life(200)
  shield_life_max = 355
  enemy:set_damage(4)

  enemy.arrow_stop_on_entity = true

  desesperate_move = false
  enemy:set_attacking_collision_mode("overlapping")
  enemy:create_sprite("enemies/"..enemy:get_breed(), "wing")
  enemy:create_sprite("enemies/"..enemy:get_breed(), "bow")
  enemy:create_sprite("enemies/"..enemy:get_breed(), "zeldo")
  enemy:create_sprite("enemies/"..enemy:get_breed(), "shield")
  enemy:get_sprite("bow"):set_opacity(0)
  shield_life = shield_life_max
  spawn_x, spawn_y = enemy:get_position()
  enemy:change_attacks_reaction("protected")

  enemy:set_arrow_reaction("custom")

  enemy.attack = {}
  enemy.attack[0] = function(subenemy) -- Bow prepare and attack
    if enemy:get_life() >= 100 then
      sol.timer.start(enemy, 1000, function()
        local i_random = math.random(5,6)
        sol.audio.play_sound(sounds[i_random])
      end)
    else
      sol.timer.start(enemy, 1000, function()
        local i_random = math.random(7,8)
        sol.audio.play_sound(sounds[i_random]) 
      end)
    end
    subenemy:get_sprite("zeldo"):set_animation("spell")
    subenemy:get_sprite("zeldo"):set_animation("flying_2")
    subenemy:get_sprite("bow"):set_opacity(255)
    subenemy:get_sprite("bow"):set_rotation(math.pi/2)
    subenemy:get_sprite("wing"):set_opacity(0)
    local i = 0
    sol.timer.start(subenemy, 25, function()
      subenemy:get_sprite("bow"):set_rotation( (math.pi/2)+(math.pi*(i/50)) )
      subenemy:get_sprite("bow"):set_xy( (i/5)-8, (i/20)-23 )
      subenemy:get_sprite("bow"):set_scale( 2-(i/72), 1 )
      i = i+2
      if i >= 80 then
        subenemy:get_sprite("bow"):set_opacity(0)
        subenemy:bow_attack_loopable(6-(enemy:get_life()/40), function()
          subenemy:launch_attack()
        end)
      else
        return true
      end
    end)
  end
  enemy.attack[1] = function(subenemy) -- Thunder spawn
    if movement ~= nil then movement:stop() end
    sol.timer.start(subenemy, 480, function()
      local i_random = math.random(9,10)
      sol.audio.play_sound(sounds[i_random])
      local i = 6-(enemy:get_life()/60)
      sol.timer.start(subenemy, 200, function()
        i = i-1
        if i > 0 then
          subenemy:spawn_thunder()
          return true
        else
          subenemy:launch_attack()
        end
      end)
    end)
  end
end

function enemy:on_custom_attack_received(custom_attack)
  if custom_attack == "arrow" then
    if enemy:is_immobilized() then
      -- Boss Immobilized
      enemy:hurt(1)
      return
    end
    local damage_calcul = 30+enemy:get_life()
    if shield_life > 0 and math.max(shield_life-damage_calcul, 0) == 0 then
      -- Shield Break
      enemy:set_push_hero_on_sword(false)
      local i_random = math.random(0,9)
      if i_random == 9 then sol.audio.play_sound(sounds[12]) else sol.audio.play_sound(sounds[11]) end
      enemy:sound_play(sounds[1])
      shield_life = 0
      enemy:get_sprite("shield"):set_color_modulation({255,255,255,0})
      enemy:change_attacks_reaction(function() enemy:hurted_after_shield_break() end)
    elseif shield_life == 0 then
      -- Boss Exposed
      shield_life = -1
      enemy:hurted_after_shield_break()
    elseif shield_life >= 0 then
      --damage Shield
      enemy:sound_play(sounds[0])
      shield_life = math.max(shield_life-damage_calcul, 0)
      enemy:get_sprite("shield"):set_color_modulation({255,(shield_life/shield_life_max)*255,(shield_life/shield_life_max)*255,255})
    end
    damage_calcul = nil
  end
end

function enemy:hurted_after_shield_break()
  if movement ~= nil then movement:stop() end
  enemy:get_sprite("wing"):set_color_modulation({255,255,255,0})
  enemy:get_sprite("bow"):set_opacity(0)
  enemy:change_attacks_reaction(2)
  sol.timer.stop_all(enemy)
  enemy:immobilize()
end

function enemy:bow_attack_loopable(number_attack, callback)
  local num_counter
  if tonumber(number_attack) == nil then
    num_counter = 0
  else
    num_counter = number_attack-1
  end
  if desesperate_move == true then -- desesperate move and infinite loop
    enemy:get_sprite("zeldo"):set_animation("flying_3_ultra", function()
      enemy:spawn_arrow()
      enemy:bow_attack_loopable(0)
    end)
  else --normal attack
    enemy:get_sprite("zeldo"):set_animation("flying_3", function()
      enemy:spawn_arrow()
      if num_counter > 0 then
        enemy:bow_attack_loopable(num_counter, callback)
      else
        if callback ~= nil then callback() end
      end
    end)
  end
end

function enemy:spawn_arrow()
  local x, y, layer = enemy:get_position()
  if (enemy:get_life() > 100) or (enemy:get_life() > 15 and math.random(0,enemy:get_life()) > 14) or (desesperate_move == true) then
    map:create_enemy({
      breed = "boss/zeldo_wave_2/gold_arrow",
      layer = layer,
      x = x,
      y = y-2,
      direction = 0,
      treasure_name = "pickable/random",
      treasure_variant = 1,
      properties = {
        {
          key = "speed",
          value = "164",
        },
        {
          key = "damage",
          value = "4",
        },
      },
    })
  else
    map:create_enemy({
      breed = "boss/zeldo_wave_2/gold_arrow",
      layer = layer,
      x = x,
      y = y-2,
      direction = 0,
      treasure_name = "pickable/random_heart_magic",
      treasure_variant = 1,
      properties = {
        {
          key = "speed",
          value = "72",
        },
        {
          key = "damage",
          value = "4",
        },
        {
          key = "repeat",
          value = "3",
        },
      },
    })
  end
end

function enemy:spawn_thunder()
  local x, y, layer = hero:get_position()
  map:create_enemy({
    breed = "boss/zeldo_wave_2/gold_thunder",
    layer = layer,
    x = x+math.random(-32, 32),
    y = y+math.random(-32, 32),
    direction = 0,
    properties = {
      {
        key = "damage",
        value = "4",
      },
    },
  })
end

function enemy:on_restarted()
  --Restarted
  enemy:set_push_hero_on_sword(true)
  enemy:get_sprite("bow"):set_animation("bow")
  enemy:get_sprite("bow"):set_opacity(0)
  enemy:get_sprite("bow"):set_xy( 0,0 )
  enemy:get_sprite("wing"):set_animation("wing")
  enemy:get_sprite("wing"):set_opacity(255)
  enemy:get_sprite("shield"):set_animation("shield")
  enemy:get_sprite("wing"):set_color_modulation({255,255,255,255})
  enemy:get_sprite("shield"):set_color_modulation({255,255,255,255})
  enemy:get_sprite("zeldo"):set_opacity(255)
  shield_life = shield_life_max
  enemy:change_attacks_reaction("protected")
  if desesperate_move == true then
    sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_2_voice/laugh")
    enemy:get_sprite("zeldo"):set_animation("laughing")
    shield_life = shield_life_max
    sol.timer.start(enemy, 2000, function()
      sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_2_voice/desesperate_move")
      sol.timer.start(enemy, 3000, function()
        local i_random = math.random(5,10)
        if shield_life > 0 then sol.audio.play_sound(sounds[i_random]) end
        return true
      end)
      enemy:bow_attack_loopable(0)
    end)
    sol.timer.start(enemy, 1000, function()
      enemy:spawn_thunder()
      return true
    end)
  else
    enemy:get_sprite("zeldo"):set_animation("flying")
    enemy:launch_attack()
  end
end

function enemy:on_pre_draw(camera)
  --draw
  if enemy:get_sprite("wing") ~= nil then
    enemy:get_sprite("wing"):set_scale(-1,1)
    map:draw_visual(enemy:get_sprite("wing"), enemy:get_position())
    enemy:get_sprite("wing"):set_scale(1,1)
    map:draw_visual(enemy:get_sprite("wing"), enemy:get_position())
  end
  if enemy:get_sprite("shield") ~= nil then
    local scale_calcul =  0.5+(math.random( math.ceil((shield_life/shield_life_max)*50),  50 )/100)
    enemy:get_sprite("shield"):set_scale( scale_calcul, scale_calcul )
    enemy:get_sprite("shield"):set_opacity(math.random(125, 150))
  end
end

function enemy:on_hurt()
  if not desesperate_move then sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_2_voice/hurt_"..math.random(1,3)) end
end

function enemy:on_dying()
  if desesperate_move == true then
    sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_2_voice/dying")
    sol.audio.play_sound("mask_break_1")
    sol.audio.play_music("none")
    map:get_entity("end_battle"):set_enabled(true)
    enemy:set_enabled(false)
  else
    if movement ~= nil then movement:stop() end
    game:start_dialog("LABORS.zeldo_wave_2.desesperate_move", function()
      enemy:change_attacks_reaction("ignored")
      enemy:set_position(spawn_x, spawn_y)
      enemy:get_sprite("zeldo"):set_opacity(125)
      desesperate_move = true
      enemy:set_life(1)
      sol.timer.stop_all(enemy)
    end)
  end
  sol.timer.stop_all(enemy)
end
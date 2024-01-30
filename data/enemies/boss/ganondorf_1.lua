--Ganondorf

local enemy = ...
local game = enemy:get_game()
local map = game:get_map()

local timer
local m = sol.movement.create("target")
m:set_speed(60)
local attacking = false

local distance_hero = 32

local phase_2 = false

local finished = false

function enemy:on_created()

  self:set_life(16*3)
  self:set_damage(4*2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_invincible()
  --Seule l'Épée de Légende peut blesser Ganondorf
  if game:get_value("get_master_sword") then self:set_attack_consequence("sword",1) end
end

function enemy:on_restarted()
  if not finished then
    m:start(self)
    attacking = false
    self:check_hero()
  else
    local sprite = enemy:get_sprite()
    sprite:set_animation("hurt")
    self:get_map():get_entity("hero"):freeze()
    sol.audio.play_music(nil)
    game:set_pause_allowed(false)
    sol.timer.start(self, 2000, function() self:end_dialog() end)
    sol.timer.start(self, 3000, function() sol.audio.play_sound("warp") sprite:fade_out() end)
    sol.timer.start(self, 6000, function() self:escape() end)
  end
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = enemy:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:check_hero()

  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < distance_hero

  if near_hero and not attacking then
    timer:stop()
    timer = nil
    enemy:attack()
  end

  timer = sol.timer.start(self, 100, function() self:check_hero() end)
end

function enemy:attack()
  m:stop()

  local angle
  if enemy:get_sprite():get_direction() == 0 then angle = 0
  elseif enemy:get_sprite():get_direction() == 1 then angle = math.pi / 2
  elseif enemy:get_sprite():get_direction() == 2 then angle = math.pi
  elseif enemy:get_sprite():get_direction() == 3 then angle = 3 * math.pi / 2 end

  local movement = sol.movement.create("straight")
  movement:set_speed(112)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  attacking = true
  sol.audio.play_sound("sword3")
  self:set_attack_consequence("sword","ignored")
  sol.timer.start(enemy,250,function()
    --Seule l'Épée de Légende peut blesser Ganondorf
    if game:get_value("get_master_sword") then self:set_attack_consequence("sword",1) end
    movement:stop()
  end)
  self:get_sprite():set_animation("sword_attack")
  sol.timer.start(enemy,500,function()
    self:restart()
  end)
end

function enemy:on_hurt()
  local life = enemy:get_life()
  if life <= 8*3 then
    if not phase_2 then
      game:start_dialog("ganondorf.battle_1.phase_2")
      phase_2 = true
      m:set_speed(72)
      distance_hero = 40
    end
  end
end

function enemy:on_dying()
  self:set_life(1)
  finished = true
end

function enemy:end_dialog()
  local sprite = enemy:get_sprite()
  sprite:set_ignore_suspend(true)
  self:get_map():get_game():start_dialog("ganondorf.battle_1.end")
end

function enemy:escape()
  self:remove()
  sol.audio.play_sound("correct")
  sol.timer.start(1000,function()
    self:get_map():get_entity("hero"):unfreeze()
    game:set_pause_allowed(true)
    map:open_doors("door_boss_2")
  end)
end
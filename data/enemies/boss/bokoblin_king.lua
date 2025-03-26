--Bokoblin King

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local transformation_effect = map:get_entity("transformation_effect")
local m = sol.movement.create("random")
m:set_speed(128)
local angle
local max_life = 12
local finished = false
local timer1 = 3000
local timer2 = 1000

function enemy:on_created()

  self:set_life(max_life)
  self:set_damage(4)
  self:set_hurt_style("boss")
  sword_sprite = self:create_sprite("enemies/boss/bokoblin_weapon")
  main_sprite = self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_hookshot_reaction("protected")
  self:set_fire_reaction("protected")
  self:set_ice_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_invincible_sprite(sword_sprite)
  self:set_attack_consequence_sprite(sword_sprite, "sword", "protected")
end

--Run to hero !
function enemy:go_hero()

  local movement = sol.movement.create("straight")
  movement:set_speed(144)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    movement:stop()
    sol.timer.start(enemy,timer2,function()
      enemy:restart()
    end)
  end

  sol.audio.play_sound("hero_seen")
  movement:start(enemy)
end

--Disappear
function enemy:disappear()
  local x, y, layer = enemy:get_position()
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sol.audio.play_sound("cape_off")
  transformation_effect:set_enabled(true)
  transformation_effect:get_sprite():set_frame(0)
  transformation_effect:set_position(x, y - 4, layer + 1)
  sol.timer.start(enemy,300,function()
    enemy:set_visible(false)
    --moves randomly
    m:start(self)
  end)
end

--Appear
function enemy:appear()
  local x, y, layer = enemy:get_position()
  sol.audio.play_sound("cape_off")
  transformation_effect:set_enabled(true)
  transformation_effect:get_sprite():set_frame(0)
  transformation_effect:set_position(x, y - 4, layer + 1)
  sol.timer.start(enemy,300,function()
    enemy:set_hookshot_reaction("protected")
    enemy:set_fire_reaction("protected")
    enemy:set_ice_reaction("protected")
    enemy:set_arrow_reaction(2)
    enemy:set_hammer_reaction(4)
    enemy:set_attack_consequence("boomerang", "protected")
    enemy:set_attack_consequence("sword", 1)
    enemy:set_attack_consequence("explosion", 2)
    enemy:set_attack_consequence("thrown_item", 1)
    enemy:set_can_attack(true)
    enemy:set_visible(true)
    local hero = map:get_hero()
    angle = enemy:get_angle(hero:get_center_position())
    enemy:go_hero()
  end)
end

--Beginning of the fight
function enemy:on_enabled()
  self:get_game():set_dialog_position("bottom")
  self:get_map():get_game():start_dialog("bokoblin_king.1.intro")
  self:get_game():set_dialog_position("auto")
end

function enemy:on_restarted()

  if not finished then
    sol.timer.start(enemy,50,function()
      enemy:disappear()
      sol.timer.start(enemy,timer1,function()
        m:stop(self)
        enemy:appear()
      end)
    end)
  else
    enemy:get_sprite():set_animation("hurt")
    self:get_map():get_entity("hero"):freeze()
    sol.audio.play_music("none")
    sol.timer.start(self, 100, function() self:end_dialog() end)
    sol.timer.start(self, 500, function() self:disappear() end)
    sol.timer.start(self, 1000, function() self:escape() end)
  end
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  main_sprite:set_direction(direction4)
  sword_sprite:set_direction(direction4)
end

function enemy:on_hurt()
  local life = enemy:get_life()
  if life <= max_life / 3 * 2 and life > max_life / 3 then
    timer1 = 2400 timer2 = 700
  elseif life <= max_life / 3 and life > 0 then
    timer1 = 1500 timer2 = 500
  elseif life <= 0 then
    self:set_life(1)
    finished = true
  end

end

function enemy:end_dialog()
  enemy:get_sprite():set_ignore_suspend(true)
  self:get_map():get_game():start_dialog("bokoblin_king.1.escape")
end

function enemy:escape()
  self:get_map():get_game():set_value("miniboss_4", true)
  self:remove()
  sol.audio.play_sound("correct")
  sol.timer.start(self:get_map(),1000,function()
    self:get_map():open_doors("door_miniboss")
    self:get_map():set_entities_enabled("telep_miniboss")
    sol.audio.play_music("creations/forgotten_legend/kokiri_shrine")
    self:get_map():get_hero():unfreeze()
  end)
end
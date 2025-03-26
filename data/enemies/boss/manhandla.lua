local enemy = ...
local heads_present = 0
local body_speed = 80

-- Manhandla: Boss with multiple heads to attack. This defines the body segment and creates the heads (green, red, blue, purple) dynamically.

function enemy:on_created()
  self:set_life(4); self:set_damage(4)
  self:create_sprite("enemies/boss/manhandla")
  self:set_size(40, 40); self:set_origin(24, 36)
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
end

-- Makes the boss go toward a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)
  local m = sol.movement.create("straight")
  m:set_speed(body_speed)

  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(self)
  last_direction8 = direction8
end

-- Four heads are created right after the body - these are attacked first.
function enemy:create_head(color)
  if color == "blue" then
    -- Blue on right: 3 life
    head = self:create_enemy({name="manhandla_head_blue", breed="boss/manhandla_head", x=12, y=6})
    head.color = "blue"
    head:get_sprite():set_direction(0)
  elseif color == "purple" then
    -- Purple on top: 4 life
    head = self:create_enemy({name="manhandla_head_purple", breed="boss/manhandla_head", x=6, y=-24})
    head.color = "purple"
    head:get_sprite():set_direction(1)
  elseif color == "green" then
    -- Green goes on left: 1 life
    head = self:create_enemy({name="manhandla_head_green", breed="boss/manhandla_head", x=-12, y=6})
    head.color = "green"
    head:get_sprite():set_direction(2)
  elseif color == "red" then
    -- Red on bottom: 2 life
    head = self:create_enemy({name="manhandla_head_red", breed="boss/manhandla_head", x=6, y=12})
    head.color = "red"
    head:get_sprite():set_direction(3)
  end
  head.body = self
  heads_present = heads_present + 1
end

function enemy:on_enabled()
  -- Create the heads.
    self:bring_to_back()
    self:set_drawn_in_y_order(false)
    self:create_head("green")
    self:create_head("red")
    self:create_head("blue")
    self:create_head("purple")
end

function enemy:on_restarted()
  local direction8 = math.random(4) * 2 - 1
  self:go(direction8)
end

function enemy:on_update()
  heads_present = self:get_map():get_entities_count("manhandla_head")
  if heads_present == 4 then
    self:set_attack_consequence("sword", "protected")
    body_speed = 80
  elseif heads_present == 3 then
    self:set_attack_consequence("sword", "protected")
    body_speed = 96
    enemy:set_life(3)
  elseif heads_present == 2 then
    self:set_attack_consequence("sword", "protected")
    body_speed = 112
    enemy:set_life(2)
  elseif heads_present == 1 then
    self:set_attack_consequence("sword", "protected")
    body_speed = 128
    enemy:set_life(1)
  else
    enemy:hurt(4)
  end
end

-- An obstacle is reached: make the boss bounce.
function enemy:on_obstacle_reached()
  local dxy = {
    { x =  1, y =  0},
    { x =  1, y = -1},
    { x =  0, y = -1},
    { x = -1, y = -1},
    { x = -1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1}
  }
  -- The current direction is last_direction8:
  -- try the three other diagonal directions.
  local try1 = (last_direction8 + 2) % 8
  local try2 = (last_direction8 + 6) % 8
  local try3 = (last_direction8 + 4) % 8

  if not self:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
    self:go(try1)
  elseif not self:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
    self:go(try2)
  else
    self:go(try3)
  end
end
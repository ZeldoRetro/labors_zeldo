----------------------------------
--
-- Explosion allowing some additional properties.
--
-- Custom properties : strength, hurtable_type_[1 to 10]
--
----------------------------------

local explosion = ...
local sprite = explosion:create_sprite("entities/explosion_bomb")
local sensible = true

local can_hurt = true

-- Configuration variables.
local strength = tonumber(explosion:get_property("strength")) or 2
local hurtable_types = {}
for i = 1, 10 do
  local type = explosion:get_property("hurtable_type_" .. i)
  if not type then
    break
  end
  table.insert(hurtable_types, type)
end
if #hurtable_types == 0 then
  hurtable_types = {"crystal", "destructible", "door", "enemy", "switch", "hero", "sensor"}
end

-- Hurt colliding hero or enemies if needed.
explosion:add_collision_test("sprite", function(explosion, entity)
  for _, type in pairs(hurtable_types) do
    if entity:get_type() == type then
      if entity:get_type() == "enemy" then
        entity:receive_attack_consequence("explosion", entity:get_attack_consequence("explosion"))
      elseif entity:get_type() == "door" then
        if entity:get_name() == nil then return end
        if string.find(entity:get_name(), "weak") then
          entity:open()
        end
      elseif entity:get_type() == "crystal" then
        if sensible then
          sensible = false
          sol.audio.play_sound("switch")
          entity:get_map():change_crystal_state()
          sol.timer.start(explosion,2000,function() sensible = true end)
        end
      elseif entity:get_type() == "switch" then
        -- Activate solid switches.
        local switch = entity
        local sprite = switch:get_sprite()
        if sprite ~= nil and sprite:get_animation_set() == "entities/Switches/solid_switch" then
          if not switch:is_activated() then
            if sensible then
              sol.audio.play_sound("switch")
              switch:set_activated(true)
              if switch:on_activated() ~= nil then switch:on_activated() end
              sol.timer.start(explosion,2000,function() sensible = true end)
            end
          end
        end
      elseif entity:get_type() == "hero" and not entity:is_invincible() and can_hurt then
        if entity:get_state() == "free" or entity:get_state() == "swimming" or entity:get_state() == "lifting" or entity:get_state() == "carrying"
        or entity:get_state() == "grabbing" or entity:get_state() == "sword loading" or entity:get_state() == "sword swinging" then
          entity:get_game():remove_life(3)
          entity:start_hurt(explosion, 1)
        end
      end
    end
  end
end)

-- Explode at creation.
explosion:register_event("on_created", function(explosion)
  explosion:set_layer_independent_collisions()
  sol.timer.start(explosion, 500, function() can_hurt = false end)
  sprite:set_animation("explosion", function()
    explosion:remove()
  end)
end)
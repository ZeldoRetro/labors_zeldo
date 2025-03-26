local enemy = ...

        local m = sol.movement.create("circle")
        m:set_center(enemy:get_map():get_entity("boss"))
        m:set_radius_speed(32)
        m:set_radius(48)
        m:start(enemy)

    local game = enemy:get_game()

    function enemy:set_shocking(shocking)
        if shocking then
            self:get_sprite():set_animation("immobilized")
            enemy:set_attack_consequence("sword", 1)
            enemy:set_attack_consequence("thrown_item", 2)
            enemy:set_arrow_reaction(2)
            enemy:set_hookshot_reaction(2)
            enemy:set_hammer_reaction(4)
            enemy:set_push_hero_on_sword(false)
        else
            self:get_sprite():set_animation("walking")
            enemy:set_attack_consequence("sword", "protected")
            enemy:set_attack_consequence("thrown_item", "protected")
            enemy:set_arrow_reaction("protected")
            enemy:set_hookshot_reaction("protected")
            enemy:set_hammer_reaction("protected")
            enemy:set_attack_consequence("explosion", 4)
            enemy:set_push_hero_on_sword(true)
        end
    end

    function enemy:is_shocking()
        return self:get_sprite():get_animation() == "shaking"
    end

    function enemy:shock()
        m:start(enemy)
        self:set_shocking(true)
        sol.timer.start(self, 4000 * math.random(), function()
            self:set_shocking(false)
            self:restart()
        end)
    end

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_attack_consequence("thrown_item", "protected")
  enemy:set_arrow_reaction("protected")
  enemy:set_hookshot_reaction("protected")
  enemy:set_hammer_reaction("protected")
  enemy:set_fire_reaction("protected")
  enemy:set_ice_reaction("protected")
  enemy:set_attack_consequence("explosion", 4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_layer(self:get_layer() + 1)
  enemy:set_layer_independent_collisions(true)
end

    function enemy:on_restarted()
        m:start(enemy)
        shocking = false
        sol.timer.start(enemy, 4000 * math.random(), function()
            self:shock()
        end)
    end
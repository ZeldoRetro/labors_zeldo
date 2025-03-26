local bari_mixin = {}

function bari_mixin.mixin(enemy)

        local m = sol.movement.create("circle")
        m:set_center(enemy:get_map():get_entity("boss"))
        m:set_radius_speed(32)
        m:set_radius(32)
        m:start(enemy)

    local game = enemy:get_game()

    function enemy:set_shocking(shocking)
        if shocking then
            self:get_sprite():set_animation("shaking")
        else
            self:get_sprite():set_animation("walking")
        end
    end

    function enemy:is_shocking()
        return self:get_sprite():get_animation() == "shaking"
    end

    function enemy:shock()
        m:start(enemy)
        self:set_shocking(true)
        sol.timer.start(self, 1500 * math.random(), function()
            self:set_shocking(false)
            self:restart()
        end)
    end

    function enemy:on_restarted()
        m:start(enemy)
        shocking = false
        sol.timer.start(enemy, 4000 * math.random(), function()
            self:shock()
        end)
    end

    function enemy:on_hurt()
      sol.timer.stop_all(enemy)
    end

    function enemy:on_hurt_by_sword(hero, enemy_sprite)
        if self:is_shocking() then
        	enemy:get_game():remove_life(3)
          hero:start_hurt(enemy, 1)
          hero:freeze()
        	hero:set_animation("electrocuted")
          sol.audio.play_sound("hero_hurt")
          sol.timer.start(1000, function () hero:unfreeze() end)
        else
          -- Why doesn't hurt() remove life?
          self:hurt(game:get_ability('sword'))
          self:remove_life(game:get_ability('sword'))
        end
    end

    function enemy:on_attacking_hero(hero, enemy_sprite)
        if self:is_shocking() then
        	enemy:get_game():remove_life(3)
          hero:start_hurt(enemy, 1)
          hero:freeze()
        	hero:set_animation("electrocuted")
          sol.audio.play_sound("hero_hurt")
          sol.timer.start(1000, function () hero:unfreeze() end)
        else
            hero:start_hurt(enemy, self:get_damage())
        end
    end
end

return bari_mixin
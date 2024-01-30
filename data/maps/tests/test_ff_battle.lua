local map = ...
local game = map:get_game()
local attacking = false
local remaining_enemies = 1

--INITIALISATION TEXTES

local attack_text = sol.text_surface.create{
  text_key = "ff_style.battle_menu.attack",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}
local tech_link_text = sol.text_surface.create{
  text_key = "ff_style.battle_menu.tech_link",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}
local item_text = sol.text_surface.create{
  text_key = "ff_style.battle_menu.item",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}
local flee_text = sol.text_surface.create{
  text_key = "ff_style.battle_menu.flee",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}

local ennemy_1_text = sol.text_surface.create{
  text_key = "ff_style.ennemy.green_goblin",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}

local link_text = sol.text_surface.create{
  text_key = "ff_style.hero.link",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}

local link_life_text = sol.text_surface.create{
  text = game:get_life().."/"..game:get_max_life(),
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "top",
}

--INITIALISATION MAP

function map:on_started()
  game:set_hud_enabled(false)
  game:set_pause_allowed(false)

  map:set_entities_enabled("cursor",false)
  cursor_action:set_enabled(true)
end

function map:on_opening_transition_finished()
  hero:freeze()
end

--AFFICHAGE TEXTES

function map:on_draw(dst_surface)

  attack_text:draw(dst_surface, 144, 168)

  tech_link_text:draw(dst_surface, 144, 184)

  item_text:draw(dst_surface, 144, 200)
  flee_text:draw(dst_surface, 144, 216)

  ennemy_1_text:draw(dst_surface, 16, 168)

  link_text:draw(dst_surface, 208, 168)

  link_life_text:draw(dst_surface, 272, 168)

end

--ATTAQUE HEROS
local function link_attack(position)
  local m = sol.movement.create("target")
  m:set_speed(196)
  m:set_target(position)
  hero:set_animation("walking")
  m:start(hero,function()
    hero:unfreeze()
    hero:start_attack()
    sol.timer.start(map, 350, function() 
      hero:freeze()
      local m = sol.movement.create("target")
      m:set_speed(196)
      m:set_target(link)
      hero:set_animation("walking")
      m:start(hero,function() hero:set_animation("stopped") end)
    end)
  end)
end

--ATTAQUE ENNEMI
local function enemy_attack(enemy)
  enemy:get_sprite():set_animation("attack",function()
    enemy:get_sprite():set_animation("walking")
    hero:start_hurt(enemy:get_damage())
    hero:freeze()
  end)
end

--ACTUALISATION VIE HEROS

hero:register_event("on_taking_damage", function(hero , damage)
  link_life_text:set_text(game:get_life().."/"..game:get_max_life())
end)

--GESTION DES INPUTS ET CURSEUR

game:register_event("on_command_pressed", function(game, command)
  if command == "action" then
    if not attacking then
      sol.audio.play_sound("ff_ok")
      if cursor_action:is_enabled() == true then
        cursor_action:set_enabled(false)
        cursor_enemy:set_enabled(true)
      else
        cursor_enemy:set_enabled(false)
        attacking = true

        enemy_attack(enemy_1)

        sol.timer.start(map,1000,function()
          link_attack(enemy_1_front)
        end)

        sol.timer.start(map,2800,function()
          --Ennemis tous morts: Bataille finie
          if remaining_enemies == 0 then
            hero:start_victory()
          --Fin du tour: Tour suivant
          else
            attacking = false
            cursor_action:set_enabled(true)
          end
        end)
      end
    end
  end
end)

--MORT DES ENNEMIS ET DISPARITION TEXTE

function enemy_1:on_dead()
  ennemy_1_text:set_text()
  remaining_enemies = remaining_enemies - 1
end
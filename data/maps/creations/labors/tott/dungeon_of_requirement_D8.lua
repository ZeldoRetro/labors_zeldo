local map = ...
local game = map:get_game()

local screamer = sol.surface.create("backgrounds/CHARA.png")
screamer:set_opacity(0)

local dark = sol.surface.create(320,240)
dark:set_opacity(0)
dark:fill_color({0,0,0})

map:register_event("on_draw",function(map,dst_surface)
  dark:draw(dst_surface)
  screamer:draw(dst_surface)
end)

function map:on_started()
  tp_switch_next:set_activated(true)
  tp_switch_previous:set_activated(true)
  game:set_pause_allowed(true)
end

function map:on_opening_transition_finished()
  sol.timer.start(map,1000,function()
    tp_switch_next:set_activated(false)
    tp_switch_previous:set_activated(false)
  end)
end

function tp_switch_next:on_activated()
  hero:teleport("creations/labors/tott/dungeon_of_requirement_D9","previous","immediate")
end

function tp_switch_previous:on_activated()
  hero:teleport("creations/labors/tott/dungeon_of_requirement_D7","next","immediate")
end

-- I L    A R R I V E

function ts:on_interaction()
  game:set_dialog_style("stone")
  game:start_dialog("ts.labors.tott.dungeon_8_info",function()
    ts:set_enabled(false)
    exit:set_enabled(false)
    map:get_entity("ts.dont_leave"):set_enabled(true)
    activate_switch:set_enabled(true)
    game:set_pause_allowed(false)
    sol.audio.play_sound("chara_laugh")
    dark:fade_in(350)
    sol.timer.start(map,10000,function()
      CHARA:set_enabled(true)
      local movement = sol.movement.create("target")
      movement:set_target(hero)
      movement:set_speed(196)
      movement:set_ignore_obstacles()
      movement:start(CHARA,function()
        screamer:set_opacity(255)
        sol.audio.play_music("none")
        sol.audio.play_sound("screamer")
        sol.timer.start(map,1000,function()
          CHARA:set_position(160,77)
          CHARA:get_sprite():set_direction(3)
          screamer:set_opacity(0)
          dark:set_opacity(0)
          game:set_dialog_style("blank")
          game:start_dialog("CHARA",function()
            print("Encore perdu. J'ai hâte de rejouer avec toi :)")
            hero:teleport("creations/labors/tott/dungeon_of_requirement_D8_C","front_ts","immediate")
          end)
        end)
      end)
    end)
  end)
end

function dont_leave_sensor_1:on_activated()
  self:set_enabled(false)
  sol.audio.play_sound("switch")
  tp_switch_previous:set_activated(true)
end
function dont_leave_sensor_2:on_activated()
  self:set_enabled(false)
  sol.audio.play_sound("switch")
  tp_switch_next:set_activated(true)
end

function activate_switch:on_activated()
  tp_switch_previous:set_activated(false)
  tp_switch_next:set_activated(false)
  dont_leave_sensor_1:set_enabled(true)
  dont_leave_sensor_2:set_enabled(true)
end
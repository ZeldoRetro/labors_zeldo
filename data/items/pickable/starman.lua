local item = ...
local map = item:get_map()
local game = item:get_game()

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished("picked_item")
end

function item:on_obtaining(variant, savegame_variable)
  local music_map = item:get_map():get_music()

  sol.audio.play_music("creations/mario_1_starman")
  game:set_value("starman",true)
  game:get_hero():set_blinking(true)
  game:set_pause_allowed(false)
  sol.timer.start(game,13000,function()
    sol.audio.play_music(music_map)
    game:set_value("starman",false)
    game:get_hero():set_blinking(false)
    game:set_pause_allowed(true)
  end)

end
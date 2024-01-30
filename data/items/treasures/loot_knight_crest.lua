--Chuchu red: Loot treasure example.

local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_knight_crest")
  self:set_amount_savegame_variable("knight_crest_amount")
  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_max_amount(99)
  self:set_assignable(true)
end

function item:on_obtained()
  self:add_amount(1)
  game:set_value("knight_crest_1st_obtained",true)
end

function item:on_using()
  self:set_finished()
end

function item:on_pickable_created(pickable)
  if game:get_value("knight_crest_1st_obtained") then self:set_brandish_when_picked(false) end
end
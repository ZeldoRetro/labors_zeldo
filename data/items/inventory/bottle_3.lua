local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("bottle_3")
end

sol.main.load_file("items/inventory/bottle")(item)
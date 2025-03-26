local item_meta=sol.main.get_metatable("item")

function item_meta:on_using()
  self:set_finished()
end
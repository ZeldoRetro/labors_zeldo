local enemy = ...

-- Red Hardhat Beetle.
sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/hardhat_beetle_red",
  life = 12,
  damage = 8,
  normal_speed = 32,
  faster_speed = 40,
  fire_reaction = "immobilized",
  push_hero_on_sword = true,
  movement_create = function()
    local m = sol.movement.create("random")
    m:set_smooth(true)
    return m
  end
})
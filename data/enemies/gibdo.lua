local enemy = ...

--Gibdo

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/gibdo",
  life = 8,
  damage = 8,
  normal_speed = 24,
  faster_speed = 32,
  pushed_when_hurt = false,
  fire_reaction = 8
})

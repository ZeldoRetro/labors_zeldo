local enemy = ...

--Taros red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/taros_green",
  sword_sprite = "enemies/taros_blue_weapon",
  life = 6,
  damage = 4,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64,
})
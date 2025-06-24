local enemy = ...

-- Soldier Oblivion green

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/soldier_oblivion_green",
  sword_sprite = "enemies/soldier_oblivion_weapon",
  life = 4,
  damage = 4,
  play_hero_seen_sound = true,
  normal_speed = 56,
  faster_speed = 88,
})
local enemy = ...

-- Zoura green

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/zoura_green",
  sword_sprite = "enemies/zoura_weapon",
  life = 4,
  damage = 1,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 32,
  faster_speed = 56,
  fire_reaction = 4,
})


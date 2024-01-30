local enemy = ...

sol.main.load_file("enemies/generic_waiting_for_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/GUAY",
  life = 3,
  damage = 4,
  normal_speed = 72,
  faster_speed = 88,
  boomerang_reaction = 1,
  hurt_style = "normal",
  push_hero_on_sword = false,
  pushed_when_hurt = true,
  asleep_animation = "asleep",
  awaking_animation = "awakening",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  awakening_sound  = nil
})

-- Remove 5 rupees when the hero is touched
enemy:register_event("on_attacking_hero", function(enemy)
  enemy:get_game():remove_money(5)
end)
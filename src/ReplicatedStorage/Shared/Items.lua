local Items = {
  -- Ingredients
  glowing_mushroom = {name="Glowing Mushroom", type="ingredient", tags={"fungus","glow","forest"}, rarity=1},
  shadow_moss     = {name="Shadow Moss",     type="ingredient", tags={"herb","dark","forest"},  rarity=1},
  frostleaf       = {name="Frostleaf",       type="ingredient", tags={"herb","ice"},            rarity=1},
  crystal_flower  = {name="Crystal Flower",  type="ingredient", tags={"crystal","rare"},        rarity=2},
  ember_shard     = {name="Ember Shard",     type="ingredient", tags={"fire","ore"},            rarity=2},
  beast_fat       = {name="Beast Fat",       type="ingredient", tags={"organic"},               rarity=1},
  -- Outputs
  potion_healing  = {name="Healing Potion",  type="consumable", tags={"potion","heal"},  value=10},
  potion_frostward = {name="Frostward Potion", type="consumable", tags={"potion","frost"}, value=25},
  salve_ice       = {name="Ice Salve",       type="consumable", tags={"salve","ice"},    value=10},
  charm_frost     = {name="Frost Charm",     type="trinket",    tags={"ice","charm"},    value=15},
}
return Items
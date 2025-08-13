return {
  warmth     = { kind="buff",   stat="+cold_resist",  base=10, perTier=5, dur=60 },
  frostward  = { kind="buff",   stat="+frost_resist", base=10, perTier=5, dur=60 },
  haste      = { kind="buff",   stat="+move_speed%",  base=5,  perTier=3, dur=20 },
  stealth    = { kind="buff",   stat="-enemy_notice", base=10, perTier=5, dur=20 },
  vigor      = { kind="buff",   stat="+max_health",   base=10, perTier=6, dur=60 },
  thorns     = { kind="buff",   stat="reflect_dmg",   base=2,  perTier=1, dur=30 },
  clarity    = { kind="buff",   stat="+crafting_xp%", base=10, perTier=5, dur=120 },
  luck       = { kind="buff",   stat="+loot_find%",   base=5,  perTier=3, dur=30 },
  luminous   = { kind="utility",stat="light_radius",  base=8,  perTier=4, dur=120 },
  antidote   = { kind="cleanse",stat="cure_poison",   base=1,  perTier=0, dur=0  },
  regen      = { kind="heal",   stat="hp_regen",      base=2,  perTier=1, dur=20 },
}
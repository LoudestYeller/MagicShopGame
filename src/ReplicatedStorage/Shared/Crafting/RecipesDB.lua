return {
  PotionBench = {
    ["beast_fat+ember_shard"] = {
      id="potion_warmth", gives={potion_warmth=1}, needs={beast_fat=1,ember_shard=1},
      effect="warmth", tier=1, xp=5, stability=0.85
    },
    ["frostleaf+glowing_mush+shadow_moss"] = {
      id="potion_frostward", gives={potion_frostward=1}, needs={frostleaf=1,glowing_mush=1,shadow_moss=1},
      effect="frostward", tier=2, xp=8, stability=0.90
    },
    ["glowing_mush+sunpetal"] = {
      id="potion_luminous", gives={potion_luminous=1}, needs={glowing_mush=1,sunpetal=1},
      effect="luminous", tier=1, xp=5, stability=0.88
    },
    ["glowing_mush+heartwood_sap"] = {
      id="potion_regen", gives={potion_regen=1}, needs={glowing_mush=1,heartwood_sap=1},
      effect="regen", tier=2, xp=7, stability=0.86
    },
    ["lucky_clover+sunpetal"] = {
      id="potion_luck", gives={potion_luck=1}, needs={lucky_clover=1,sunpetal=1},
      effect="luck", tier=2, xp=7, stability=0.87
    },
    ["sky_salt+sunpetal"] = {
      id="potion_antidote", gives={potion_antidote=1}, needs={sky_salt=1,sunpetal=1},
      effect="antidote", tier=1, xp=5, stability=0.90
    },
    ["echo_silk+shadow_moss"] = {
      id="potion_stealth", gives={potion_stealth=1}, needs={echo_silk=1,shadow_moss=1},
      effect="stealth", tier=2, xp=8, stability=0.84
    },
    ["heartwood_sap+nightshade"] = {
      id="potion_antidote", gives={potion_antidote=1}, needs={heartwood_sap=1,nightshade=1},
      effect="antidote", tier=2, xp=7, stability=0.82
    },
    ["echo_silk+sky_salt"] = {
      id="potion_haste", gives={potion_haste=1}, needs={echo_silk=1,sky_salt=1},
      effect="haste", tier=2, xp=8, stability=0.86
    },
    ["beast_fat+brimstone_powder"] = {
      id="potion_warmth_t2", gives={potion_warmth_t2=1}, needs={beast_fat=1,brimstone_powder=1},
      effect="warmth", tier=2, xp=8, stability=0.83
    },
  },

  Enchanter = {
    ["crystal_flower+echo_silk"] = {
      id="charm_haste", gives={charm_haste=1}, needs={crystal_flower=1,echo_silk=1},
      effect="haste", tier=2, xp=10, stability=0.88
    },
    ["aether_quartz+sunpetal"] = {
      id="charm_luminous", gives={charm_luminous=1}, needs={aether_quartz=1,sunpetal=1},
      effect="luminous", tier=3, xp=14, stability=0.86
    },
    ["ghost_orchid+shadow_moss"] = {
      id="charm_stealth", gives={charm_stealth=1}, needs={ghost_orchid=1,shadow_moss=1},
      effect="stealth", tier=3, xp=14, stability=0.82
    },
    ["echo_silk+lucky_clover"] = {
      id="charm_luck", gives={charm_luck=1}, needs={echo_silk=1,lucky_clover=1},
      effect="luck", tier=2, xp=10, stability=0.87
    },
    ["crystal_flower+heartwood_sap"] = {
      id="charm_vigor", gives={charm_vigor=1}, needs={crystal_flower=1,heartwood_sap=1},
      effect="vigor", tier=2, xp=10, stability=0.89
    },
    ["sky_salt+void_ichor"] = {
      id="charm_antidote", gives={charm_antidote=1}, needs={sky_salt=1,void_ichor=1},
      effect="antidote", tier=3, xp=14, stability=0.78
    },
  },

  Forge = {
    ["heartwood_sap+iron_dust"] = {
      id="plating_thorns", gives={plating_thorns=1}, needs={heartwood_sap=1,iron_dust=1},
      effect="thorns", tier=1, xp=6, stability=0.90
    },
    ["frostleaf+iron_dust"] = {
      id="plating_frostward", gives={plating_frostward=1}, needs={frostleaf=1,iron_dust=1},
      effect="frostward", tier=1, xp=6, stability=0.90
    },
    ["brimstone_powder+iron_dust"] = {
      id="plating_warmth", gives={plating_warmth=1}, needs={brimstone_powder=1,iron_dust=1},
      effect="warmth", tier=1, xp=6, stability=0.88
    },
    ["aether_quartz+iron_dust"] = {
      id="plating_haste", gives={plating_haste=1}, needs={aether_quartz=1,iron_dust=1},
      effect="haste", tier=2, xp=10, stability=0.86
    },
  },
}
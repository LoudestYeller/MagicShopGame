# Magic Shop — Gameplay Blueprint (GDD-lite)
Core loop: Gather → Inventory → Craft → List → Sell → Reward (Tutorial).

Progression:
- Stations: PotionBench, Enchanter, (WandTable later).
- Unlocks: rooms/stations, décor, badges.
- Currencies: cash; fee on listings (5%).
- Realms: seasonal/biome later.

Content: 
- Ingredients (IDs): glowing_mushroom, shadow_moss, frostleaf, crystal_flower, ember_shard, beast_fat
- Outputs (IDs): potion_healing, salve_ice, charm_frost
- Tags: fire/ice/herb/fungus/crystal/etc., used for NPC trends.

Player actions:
- Gather: nodes with ItemId attribute grant IDs.
- Craft: choose station + 2–3 inputs; server validates vs Recipes and DataService.
- Sell: list items in display case; NPCs buy within price band.

Tutorial milestones:
FirstGather → FirstCraft → FirstStock → FirstSale → Reward (100 cash + recipe scroll).
extends Node
class_name ItemDatabase
## Static database of all items in the game
## Access via ItemDatabase.get_item("item_id")

# Item definitions - loaded at startup
static var items: Dictionary = {}
static var recipes: Dictionary = {}
static var machines: Dictionary = {}

static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return

	_load_items()
	_load_recipes()
	_load_machines()
	_initialized = true


static func _load_items() -> void:
	# Botanical - Raw
	_add_item("moonpetal", "Moonpetal", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.RAW, 2, 60.0)
	_add_item("firefern", "Firefern", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.RAW, 3, 120.0)
	_add_item("whisperroot", "Whisperroot", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.RAW, 4, 180.0)
	_add_item("frostbloom", "Frostbloom", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.RAW, 5, 300.0)
	_add_item("shadowmoss", "Shadowmoss", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.RAW, 6, 360.0)

	# Botanical - Processed
	_add_item("lunar_essence", "Lunar Essence", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.PROCESSED, 8)
	_add_item("ember_extract", "Ember Extract", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.PROCESSED, 12)
	_add_item("spirit_sap", "Spirit Sap", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.PROCESSED, 16)
	_add_item("ice_nectar", "Ice Nectar", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.PROCESSED, 20)
	_add_item("dark_residue", "Dark Residue", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.PROCESSED, 24)

	# Botanical - Refined
	_add_item("pure_moonlight", "Pure Moonlight", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.REFINED, 30)
	_add_item("condensed_flame", "Condensed Flame", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.REFINED, 45)
	_add_item("ghost_vapor", "Ghost Vapor", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.REFINED, 50)

	# Mineral - Raw
	_add_item("crystalstone", "Crystalstone", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 5)
	_add_item("iron_ore", "Iron Ore", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 3)
	_add_item("salt_rock", "Salt Rock", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 2)

	# Mineral - Processed
	_add_item("crystal_dust", "Crystal Dust", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.PROCESSED, 20)
	_add_item("pure_salt", "Pure Salt", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.PROCESSED, 8)
	_add_item("iron_filings", "Iron Filings", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.PROCESSED, 12)

	# Mineral - Refined
	_add_item("resonant_shard", "Resonant Shard", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.REFINED, 60)
	_add_item("blessed_salt", "Blessed Salt", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.REFINED, 30)
	_add_item("tempered_iron", "Tempered Iron", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.REFINED, 40)

	# Creature - Raw
	_add_item("slime_glob", "Slime Glob", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 4)
	_add_item("wolf_fang", "Wolf Fang", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 10)
	_add_item("owl_feather", "Owl Feather", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 8)
	_add_item("rabbit_foot", "Rabbit Foot", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 15, 0.0, ItemData.Rarity.UNCOMMON)

	# Creature - Processed
	_add_item("slime_extract", "Slime Extract", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.PROCESSED, 15)
	_add_item("fang_powder", "Fang Powder", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.PROCESSED, 30)
	_add_item("feather_dust", "Feather Dust", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.PROCESSED, 20)

	# Creature - Refined
	_add_item("purified_gel", "Purified Gel", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.REFINED, 45)

	# Fish
	_add_item("common_fish", "Common Fish", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 3)
	_add_item("trout", "Trout", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 5)
	_add_item("eel", "Eel", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 12, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("spirit_fish", "Spirit Fish", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 50, 0.0, ItemData.Rarity.RARE)

	# Elemental
	_add_item("raw_mana", "Raw Mana", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 10)
	_add_item("spring_water", "Spring Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 1)
	_add_item("water", "Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 1)

	# Elemental - Processed
	_add_item("mana_drops", "Mana Drops", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.PROCESSED, 25)
	_add_item("blessed_water", "Blessed Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.PROCESSED, 5)

	# Elemental - Refined
	_add_item("pure_mana", "Pure Mana", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.REFINED, 75)
	_add_item("holy_water", "Holy Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.REFINED, 20)

	# Potions - Common (basic_cauldron)
	_add_item("health_potion", "Health Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 15)
	_add_item("mana_potion", "Mana Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 15)
	_add_item("stamina_tonic", "Stamina Tonic", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 12)
	_add_item("antidote", "Antidote", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 20)

	# Potions - Uncommon (copper_cauldron)
	_add_item("fire_resistance", "Fire Resistance Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 50, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("night_vision", "Night Vision Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 45, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("frost_shield", "Frost Shield Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 55, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("water_breathing", "Water Breathing Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 40, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("featherfall", "Featherfall Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 35, 0.0, ItemData.Rarity.UNCOMMON)

	# Potions - Rare (silver_cauldron)
	_add_item("invisibility", "Invisibility Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 200, 0.0, ItemData.Rarity.RARE)
	_add_item("giant_strength", "Giant Strength Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 180, 0.0, ItemData.Rarity.RARE)
	_add_item("haste_potion", "Haste Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 150, 0.0, ItemData.Rarity.RARE)
	_add_item("stone_skin", "Stone Skin Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 160, 0.0, ItemData.Rarity.RARE)

	# Set processing chains (must be after all items are defined)
	# Raw → Processed (extraction machines)
	_set_processing("moonpetal", "lunar_essence", "herb_press")
	_set_processing("firefern", "ember_extract", "herb_press")
	_set_processing("whisperroot", "spirit_sap", "mortar_pestle")
	_set_processing("frostbloom", "ice_nectar", "mana_tap")
	_set_processing("shadowmoss", "dark_residue", "mana_tap")
	_set_processing("crystalstone", "crystal_dust", "grinder")
	_set_processing("salt_rock", "pure_salt", "grinder")
	_set_processing("iron_ore", "iron_filings", "grinder")
	_set_processing("slime_glob", "slime_extract", "specimen_jar")
	_set_processing("wolf_fang", "fang_powder", "specimen_jar")
	_set_processing("owl_feather", "feather_dust", "specimen_jar")
	_set_processing("spring_water", "blessed_water", "mortar_pestle")
	_set_processing("raw_mana", "mana_drops", "mortar_pestle")
	# Processed → Refined (processing machines)
	_set_processing("lunar_essence", "pure_moonlight", "alembic_still")
	_set_processing("ember_extract", "condensed_flame", "alembic_still")
	_set_processing("spirit_sap", "ghost_vapor", "alembic_still")
	_set_processing("crystal_dust", "resonant_shard", "crystallizer")
	_set_processing("pure_salt", "blessed_salt", "crystallizer")
	_set_processing("iron_filings", "tempered_iron", "calcinator")
	_set_processing("slime_extract", "purified_gel", "calcinator")
	_set_processing("mana_drops", "pure_mana", "calcinator")
	_set_processing("blessed_water", "holy_water", "calcinator")


static func _add_item(id: String, name: String, category: ItemData.ItemCategory, tier: ItemData.ItemTier, value: int, grow_time: float = 0.0, rarity: ItemData.Rarity = ItemData.Rarity.COMMON) -> void:
	var item = ItemData.new()
	item.id = id
	item.display_name = name
	item.category = category
	item.tier = tier
	item.base_value = value
	item.grow_time = grow_time
	item.rarity = rarity
	items[id] = item


static func _set_processing(item_id: String, target_id: String, machine: String) -> void:
	if items.has(item_id):
		items[item_id].processes_into = target_id
		items[item_id].process_machine = machine


static func _load_recipes() -> void:
	# Basic potions
	_add_recipe("health_potion", "Health Potion", "health_potion",
		[{"item_id": "moonpetal", "amount": 2}, {"item_id": "water", "amount": 1}],
		"basic_cauldron", 30.0)

	_add_recipe("mana_potion", "Mana Potion", "mana_potion",
		[{"item_id": "whisperroot", "amount": 2}, {"item_id": "water", "amount": 1}],
		"basic_cauldron", 45.0)

	_add_recipe("stamina_tonic", "Stamina Tonic", "stamina_tonic",
		[{"item_id": "moonpetal", "amount": 1}, {"item_id": "whisperroot", "amount": 1}, {"item_id": "water", "amount": 1}],
		"basic_cauldron", 40.0)

	_add_recipe("antidote", "Antidote", "antidote",
		[{"item_id": "moonpetal", "amount": 1}, {"item_id": "pure_salt", "amount": 1}, {"item_id": "water", "amount": 1}],
		"basic_cauldron", 60.0)

	# Mortar & Pestle recipes (starting extraction machine)
	_add_recipe("spirit_sap", "Extract Spirit Sap", "spirit_sap",
		[{"item_id": "whisperroot", "amount": 2}],
		"mortar_pestle", 30.0)

	_add_recipe("blessed_water", "Bless Water", "blessed_water",
		[{"item_id": "spring_water", "amount": 3}],
		"mortar_pestle", 20.0)

	_add_recipe("mana_drops", "Refine Mana Drops", "mana_drops",
		[{"item_id": "raw_mana", "amount": 2}],
		"mortar_pestle", 45.0)

	# Herb Press recipes
	_add_recipe("lunar_essence", "Extract Lunar Essence", "lunar_essence",
		[{"item_id": "moonpetal", "amount": 2}],
		"herb_press", 45.0)

	_add_recipe("ember_extract", "Extract Ember", "ember_extract",
		[{"item_id": "firefern", "amount": 2}],
		"herb_press", 60.0)

	# Grinder recipes
	_add_recipe("crystal_dust", "Grind Crystal", "crystal_dust",
		[{"item_id": "crystalstone", "amount": 1}],
		"grinder", 60.0)

	_add_recipe("pure_salt", "Purify Salt", "pure_salt",
		[{"item_id": "salt_rock", "amount": 2}],
		"grinder", 30.0)

	_add_recipe("iron_filings", "Grind Iron", "iron_filings",
		[{"item_id": "iron_ore", "amount": 2}],
		"grinder", 45.0)

	# Specimen Jar recipes (creature extraction)
	_add_recipe("slime_extract", "Extract Slime", "slime_extract",
		[{"item_id": "slime_glob", "amount": 2}],
		"specimen_jar", 40.0)

	_add_recipe("fang_powder", "Grind Fang", "fang_powder",
		[{"item_id": "wolf_fang", "amount": 1}],
		"specimen_jar", 50.0)

	_add_recipe("feather_dust", "Process Feathers", "feather_dust",
		[{"item_id": "owl_feather", "amount": 2}],
		"specimen_jar", 35.0)

	# Mana Tap recipes (magical extraction)
	_add_recipe("ice_nectar", "Extract Ice Nectar", "ice_nectar",
		[{"item_id": "frostbloom", "amount": 2}],
		"mana_tap", 45.0)

	_add_recipe("dark_residue", "Extract Dark Residue", "dark_residue",
		[{"item_id": "shadowmoss", "amount": 2}],
		"mana_tap", 50.0)

	# --- Processing recipes (processed → refined) ---

	# Alembic Still recipes (botanical refinement)
	_add_recipe("pure_moonlight", "Distill Moonlight", "pure_moonlight",
		[{"item_id": "lunar_essence", "amount": 2}],
		"alembic_still", 120.0)

	_add_recipe("condensed_flame", "Condense Flame", "condensed_flame",
		[{"item_id": "ember_extract", "amount": 2}],
		"alembic_still", 150.0)

	_add_recipe("ghost_vapor", "Distill Ghost Vapor", "ghost_vapor",
		[{"item_id": "spirit_sap", "amount": 2}, {"item_id": "water", "amount": 1}],
		"alembic_still", 120.0)

	# Crystallizer recipes (mineral refinement)
	_add_recipe("resonant_shard", "Grow Crystal Shard", "resonant_shard",
		[{"item_id": "crystal_dust", "amount": 2}],
		"crystallizer", 180.0)

	_add_recipe("blessed_salt", "Bless Salt", "blessed_salt",
		[{"item_id": "pure_salt", "amount": 3}],
		"crystallizer", 120.0)

	# Calcinator recipes (general refinement)
	_add_recipe("tempered_iron", "Temper Iron", "tempered_iron",
		[{"item_id": "iron_filings", "amount": 3}],
		"calcinator", 150.0)

	_add_recipe("purified_gel", "Purify Slime Gel", "purified_gel",
		[{"item_id": "slime_extract", "amount": 2}],
		"calcinator", 120.0)

	_add_recipe("pure_mana", "Purify Mana", "pure_mana",
		[{"item_id": "mana_drops", "amount": 3}],
		"calcinator", 150.0)

	_add_recipe("holy_water", "Sanctify Water", "holy_water",
		[{"item_id": "blessed_water", "amount": 3}],
		"calcinator", 120.0)

	# --- Brewing recipes (higher tier potions) ---

	# Copper Cauldron recipes (uncommon potions)
	_add_recipe("fire_resistance", "Fire Resistance Potion", "fire_resistance",
		[{"item_id": "ember_extract", "amount": 2}, {"item_id": "blessed_water", "amount": 1}],
		"copper_cauldron", 90.0)

	_add_recipe("night_vision", "Night Vision Potion", "night_vision",
		[{"item_id": "lunar_essence", "amount": 2}, {"item_id": "owl_feather", "amount": 1}, {"item_id": "water", "amount": 1}],
		"copper_cauldron", 80.0)

	_add_recipe("frost_shield", "Frost Shield Potion", "frost_shield",
		[{"item_id": "ice_nectar", "amount": 2}, {"item_id": "crystal_dust", "amount": 1}, {"item_id": "water", "amount": 1}],
		"copper_cauldron", 100.0)

	_add_recipe("water_breathing", "Water Breathing Potion", "water_breathing",
		[{"item_id": "spirit_sap", "amount": 2}, {"item_id": "blessed_water", "amount": 1}],
		"copper_cauldron", 60.0)

	_add_recipe("featherfall", "Featherfall Potion", "featherfall",
		[{"item_id": "feather_dust", "amount": 2}, {"item_id": "spirit_sap", "amount": 1}, {"item_id": "water", "amount": 1}],
		"copper_cauldron", 50.0)

	# Silver Cauldron recipes (rare potions)
	_add_recipe("invisibility", "Invisibility Potion", "invisibility",
		[{"item_id": "dark_residue", "amount": 2}, {"item_id": "ghost_vapor", "amount": 1}, {"item_id": "mana_drops", "amount": 1}],
		"silver_cauldron", 180.0)

	_add_recipe("giant_strength", "Giant Strength Potion", "giant_strength",
		[{"item_id": "fang_powder", "amount": 2}, {"item_id": "condensed_flame", "amount": 1}, {"item_id": "pure_salt", "amount": 1}],
		"silver_cauldron", 150.0)

	_add_recipe("haste_potion", "Haste Potion", "haste_potion",
		[{"item_id": "pure_moonlight", "amount": 1}, {"item_id": "mana_drops", "amount": 2}, {"item_id": "blessed_water", "amount": 1}],
		"silver_cauldron", 120.0)

	_add_recipe("stone_skin", "Stone Skin Potion", "stone_skin",
		[{"item_id": "resonant_shard", "amount": 1}, {"item_id": "purified_gel", "amount": 1}, {"item_id": "iron_filings", "amount": 1}],
		"silver_cauldron", 160.0)


static func _add_recipe(id: String, name: String, output: String, ingredients: Array, machine: String, time: float) -> void:
	var recipe = RecipeData.new()
	recipe.id = id
	recipe.display_name = name
	recipe.output_item_id = output
	recipe.output_amount = 1
	recipe.required_machine = machine
	recipe.craft_time = time

	for ing in ingredients:
		recipe.ingredients.append(ing)

	recipes[id] = recipe


static func _load_machines() -> void:
	_add_machine("mortar_pestle", "Mortar & Pestle", MachineData.MachineCategory.EXTRACTION, 0)
	_add_machine("herb_press", "Herb Press", MachineData.MachineCategory.EXTRACTION, 100)
	_add_machine("grinder", "Grinder", MachineData.MachineCategory.EXTRACTION, 250)
	_add_machine("specimen_jar", "Specimen Jar", MachineData.MachineCategory.EXTRACTION, 500)
	_add_machine("mana_tap", "Mana Tap", MachineData.MachineCategory.EXTRACTION, 750)

	_add_machine("alembic_still", "Alembic Still", MachineData.MachineCategory.PROCESSING, 1000)
	_add_machine("crystallizer", "Crystallizer", MachineData.MachineCategory.PROCESSING, 1500)
	_add_machine("calcinator", "Calcinator", MachineData.MachineCategory.PROCESSING, 2000)

	_add_machine("mana_infuser", "Mana Infuser", MachineData.MachineCategory.REFINEMENT, 10000)
	_add_machine("enchanting_circle", "Enchanting Circle", MachineData.MachineCategory.REFINEMENT, 15000)

	_add_machine("basic_cauldron", "Basic Cauldron", MachineData.MachineCategory.BREWING, 0)
	_add_machine("copper_cauldron", "Copper Cauldron", MachineData.MachineCategory.BREWING, 500)
	_add_machine("silver_cauldron", "Silver Cauldron", MachineData.MachineCategory.BREWING, 2000)
	_add_machine("enchanted_cauldron", "Enchanted Cauldron", MachineData.MachineCategory.BREWING, 10000)

	_add_machine("storage_crate", "Storage Crate", MachineData.MachineCategory.STORAGE, 100)
	_add_machine("storage_chest", "Storage Chest", MachineData.MachineCategory.STORAGE, 500)


static func _add_machine(id: String, name: String, category: MachineData.MachineCategory, cost: int) -> void:
	var machine = MachineData.new()
	machine.id = id
	machine.display_name = name
	machine.category = category
	machine.unlock_cost = cost
	machines[id] = machine


# Accessors
static func get_item(item_id: String) -> ItemData:
	if not _initialized:
		initialize()
	return items.get(item_id)


static func get_recipe(recipe_id: String) -> RecipeData:
	if not _initialized:
		initialize()
	return recipes.get(recipe_id)


static func get_machine(machine_id: String) -> MachineData:
	if not _initialized:
		initialize()
	return machines.get(machine_id)


static func get_all_items() -> Dictionary:
	if not _initialized:
		initialize()
	return items


static func get_all_recipes() -> Dictionary:
	if not _initialized:
		initialize()
	return recipes


static func get_all_machines() -> Dictionary:
	if not _initialized:
		initialize()
	return machines


static func get_recipes_for_machine(machine_id: String) -> Array:
	if not _initialized:
		initialize()
	var result: Array = []
	for recipe_id in recipes:
		var recipe = recipes[recipe_id]
		if _is_machine_compatible(machine_id, recipe.required_machine):
			result.append(recipe)
	return result


static func _is_machine_compatible(machine_id: String, required_machine: String) -> bool:
	if machine_id == required_machine:
		return true
	# Higher-tier cauldrons can brew lower-tier cauldron recipes
	var cauldron_tiers = ["basic_cauldron", "copper_cauldron", "silver_cauldron", "enchanted_cauldron"]
	var machine_tier = cauldron_tiers.find(machine_id)
	var required_tier = cauldron_tiers.find(required_machine)
	if machine_tier >= 0 and required_tier >= 0:
		return machine_tier >= required_tier
	return false

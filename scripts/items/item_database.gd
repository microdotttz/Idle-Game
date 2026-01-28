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

	# Botanical - Refined
	_add_item("pure_moonlight", "Pure Moonlight", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.REFINED, 30)
	_add_item("condensed_flame", "Condensed Flame", ItemData.ItemCategory.BOTANICAL, ItemData.ItemTier.REFINED, 45)

	# Mineral - Raw
	_add_item("crystalstone", "Crystalstone", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 5)
	_add_item("iron_ore", "Iron Ore", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 3)
	_add_item("salt_rock", "Salt Rock", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.RAW, 2)

	# Mineral - Processed
	_add_item("crystal_dust", "Crystal Dust", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.PROCESSED, 20)
	_add_item("pure_salt", "Pure Salt", ItemData.ItemCategory.MINERAL, ItemData.ItemTier.PROCESSED, 8)

	# Creature
	_add_item("slime_glob", "Slime Glob", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 4)
	_add_item("wolf_fang", "Wolf Fang", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 10)
	_add_item("owl_feather", "Owl Feather", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 8)
	_add_item("rabbit_foot", "Rabbit Foot", ItemData.ItemCategory.CREATURE, ItemData.ItemTier.RAW, 15, 0.0, ItemData.Rarity.UNCOMMON)

	# Fish
	_add_item("common_fish", "Common Fish", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 3)
	_add_item("trout", "Trout", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 5)
	_add_item("eel", "Eel", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 12, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("spirit_fish", "Spirit Fish", ItemData.ItemCategory.FISH, ItemData.ItemTier.RAW, 50, 0.0, ItemData.Rarity.RARE)

	# Elemental
	_add_item("raw_mana", "Raw Mana", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 10)
	_add_item("spring_water", "Spring Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 1)
	_add_item("water", "Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.RAW, 1)

	# Processed Elemental
	_add_item("mana_drops", "Mana Drops", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.PROCESSED, 25)
	_add_item("blessed_water", "Blessed Water", ItemData.ItemCategory.ELEMENTAL, ItemData.ItemTier.PROCESSED, 5)

	# Potions
	_add_item("health_potion", "Health Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 15)
	_add_item("mana_potion", "Mana Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 15)
	_add_item("stamina_tonic", "Stamina Tonic", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 12)
	_add_item("antidote", "Antidote", ItemData.ItemCategory.POTION, ItemData.ItemTier.PROCESSED, 20)

	_add_item("fire_resistance", "Fire Resistance Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 50, 0.0, ItemData.Rarity.UNCOMMON)
	_add_item("night_vision", "Night Vision Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 45, 0.0, ItemData.Rarity.UNCOMMON)

	_add_item("invisibility", "Invisibility Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 200, 0.0, ItemData.Rarity.RARE)
	_add_item("giant_strength", "Giant Strength Potion", ItemData.ItemCategory.POTION, ItemData.ItemTier.REFINED, 180, 0.0, ItemData.Rarity.RARE)

	# Set processing chains (must be after all items are defined)
	_set_processing("moonpetal", "lunar_essence", "herb_press")
	_set_processing("firefern", "ember_extract", "herb_press")
	_set_processing("whisperroot", "spirit_sap", "mortar_pestle")
	_set_processing("crystalstone", "crystal_dust", "grinder")
	_set_processing("salt_rock", "pure_salt", "grinder")
	_set_processing("spring_water", "blessed_water", "mortar_pestle")
	_set_processing("raw_mana", "mana_drops", "mortar_pestle")


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

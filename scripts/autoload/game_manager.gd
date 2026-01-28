extends Node
## GameManager - Global game state singleton
## Manages inventory, gold, reputation, and game progression

signal gold_changed(new_amount: int)
signal mana_changed(new_amount: int)
signal reputation_changed(new_amount: int)
signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)

# Currency
var gold: int = 100:
	set(value):
		gold = max(0, value)
		gold_changed.emit(gold)

var mana: int = 0:
	set(value):
		mana = max(0, value)
		mana_changed.emit(mana)

# Progression
var reputation: int = 0:
	set(value):
		reputation = max(0, value)
		reputation_changed.emit(reputation)

var reputation_tier: int = 1

# Inventory: Dictionary of item_id -> quantity
var inventory: Dictionary = {}

# Unlocked recipes, machines, locations
var unlocked_recipes: Array[String] = []
var unlocked_machines: Array[String] = []
var unlocked_locations: Array[String] = []

# Skills
var skills: Dictionary = {
	"brewing": 1,
	"herbalism": 1,
	"fishing": 1,
	"hunting": 1,
	"foraging": 1
}

# Statistics
var stats: Dictionary = {
	"potions_brewed": 0,
	"potions_sold": 0,
	"gold_earned": 0,
	"items_gathered": 0,
	"fish_caught": 0,
	"creatures_hunted": 0
}


func _ready() -> void:
	# Initialize starting items
	_initialize_starting_inventory()
	_initialize_starting_unlocks()


func _initialize_starting_inventory() -> void:
	# Give player some starting materials
	add_item("moonpetal", 10)
	add_item("whisperroot", 5)
	add_item("water", 20)


func _initialize_starting_unlocks() -> void:
	# Starting recipes (mortar_pestle + basic_cauldron recipes)
	unlocked_recipes = ["health_potion", "mana_potion", "stamina_tonic", "antidote", "spirit_sap", "blessed_water", "mana_drops"]

	# Starting machines
	unlocked_machines = ["mortar_pestle", "basic_cauldron"]

	# Starting locations
	unlocked_locations = ["village_pond", "forest_edge", "meadow"]


# Inventory Management
func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	item_added.emit(item_id, amount)
	stats["items_gathered"] += amount


func remove_item(item_id: String, amount: int = 1) -> bool:
	if not has_item(item_id, amount):
		return false
	inventory[item_id] -= amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	item_removed.emit(item_id, amount)
	return true


func has_item(item_id: String, amount: int = 1) -> bool:
	return inventory.get(item_id, 0) >= amount


func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)


# Currency Management
func add_gold(amount: int) -> void:
	gold += amount
	stats["gold_earned"] += amount


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false


func can_afford(amount: int) -> bool:
	return gold >= amount


# Progression
func add_reputation(amount: int) -> void:
	reputation += amount
	_check_reputation_tier()


func _check_reputation_tier() -> void:
	# Reputation thresholds for each tier
	var thresholds = [0, 100, 500, 1500, 5000, 15000, 50000]
	for i in range(thresholds.size() - 1, -1, -1):
		if reputation >= thresholds[i]:
			if reputation_tier < i + 1:
				reputation_tier = i + 1
				_on_tier_up(reputation_tier)
			break


func _on_tier_up(new_tier: int) -> void:
	print("Reputation tier up! Now tier ", new_tier)
	# Unlock new content based on tier


# Skills
func add_skill_xp(skill_name: String, amount: int) -> void:
	if skills.has(skill_name):
		# Simple leveling: every 100 XP = 1 level (can make more complex)
		skills[skill_name] += amount


func get_skill_level(skill_name: String) -> int:
	return skills.get(skill_name, 1)


# Recipe/Machine/Location unlocks
func unlock_recipe(recipe_id: String) -> void:
	if recipe_id not in unlocked_recipes:
		unlocked_recipes.append(recipe_id)


func unlock_machine(machine_id: String) -> void:
	if machine_id not in unlocked_machines:
		unlocked_machines.append(machine_id)
		# Auto-unlock all recipes for this machine
		var machine_recipes = ItemDatabase.get_recipes_for_machine(machine_id)
		for recipe in machine_recipes:
			unlock_recipe(recipe.id)


func unlock_location(location_id: String) -> void:
	if location_id not in unlocked_locations:
		unlocked_locations.append(location_id)


func is_recipe_unlocked(recipe_id: String) -> bool:
	return recipe_id in unlocked_recipes


func is_machine_unlocked(machine_id: String) -> bool:
	return machine_id in unlocked_machines


func is_location_unlocked(location_id: String) -> bool:
	return location_id in unlocked_locations


# Save/Load helpers
func get_save_data() -> Dictionary:
	return {
		"gold": gold,
		"mana": mana,
		"reputation": reputation,
		"reputation_tier": reputation_tier,
		"inventory": inventory.duplicate(),
		"unlocked_recipes": unlocked_recipes.duplicate(),
		"unlocked_machines": unlocked_machines.duplicate(),
		"unlocked_locations": unlocked_locations.duplicate(),
		"skills": skills.duplicate(),
		"stats": stats.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	gold = data.get("gold", 100)
	mana = data.get("mana", 0)
	reputation = data.get("reputation", 0)
	reputation_tier = data.get("reputation_tier", 1)
	inventory = data.get("inventory", {})
	unlocked_recipes = data.get("unlocked_recipes", [])
	unlocked_machines = data.get("unlocked_machines", [])
	unlocked_locations = data.get("unlocked_locations", [])
	skills = data.get("skills", {})
	stats = data.get("stats", {})

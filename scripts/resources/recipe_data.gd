extends Resource
class_name RecipeData
## RecipeData - Defines a crafting/brewing recipe

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# Input ingredients: Array of { "item_id": String, "amount": int }
@export var ingredients: Array[Dictionary] = []

# Output
@export var output_item_id: String = ""
@export var output_amount: int = 1

# Crafting requirements
@export var required_machine: String = ""  # Machine type needed (e.g., "cauldron")
@export var craft_time: float = 30.0  # Seconds to craft
@export var required_skill_level: int = 1  # Minimum brewing skill

# Discovery
@export var is_discovered_by_default: bool = false
@export var discovery_hint: String = ""  # Hint shown before discovery


func can_craft(inventory: Dictionary, skill_level: int = 1) -> bool:
	# Check skill level
	if skill_level < required_skill_level:
		return false

	# Check ingredients
	for ingredient in ingredients:
		var item_id = ingredient.get("item_id", "")
		var amount = ingredient.get("amount", 1)
		if inventory.get(item_id, 0) < amount:
			return false

	return true


func get_missing_ingredients(inventory: Dictionary) -> Array[Dictionary]:
	var missing: Array[Dictionary] = []

	for ingredient in ingredients:
		var item_id = ingredient.get("item_id", "")
		var required = ingredient.get("amount", 1)
		var have = inventory.get(item_id, 0)

		if have < required:
			missing.append({
				"item_id": item_id,
				"required": required,
				"have": have,
				"need": required - have
			})

	return missing


func consume_ingredients(inventory: Dictionary) -> bool:
	if not can_craft(inventory):
		return false

	for ingredient in ingredients:
		var item_id = ingredient.get("item_id", "")
		var amount = ingredient.get("amount", 1)
		GameManager.remove_item(item_id, amount)

	return true

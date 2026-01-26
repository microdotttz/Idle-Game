extends Resource
class_name ItemData
## ItemData - Defines properties of an item/ingredient

enum ItemCategory {
	BOTANICAL,
	MINERAL,
	CREATURE,
	ELEMENTAL,
	FISH,
	POTION,
	OTHER
}

enum ItemTier {
	RAW,
	PROCESSED,
	REFINED,
	ENCHANTED
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

@export var category: ItemCategory = ItemCategory.BOTANICAL
@export var tier: ItemTier = ItemTier.RAW
@export var rarity: Rarity = Rarity.COMMON

@export var base_value: int = 1  # Sell price
@export var stack_size: int = 99

# For growable items
@export var grow_time: float = 0.0  # Seconds to grow (0 = not growable)
@export var seed_id: String = ""  # ID of seed item for this plant

# Processing
@export var processes_into: String = ""  # Item ID this becomes when processed
@export var process_machine: String = ""  # Machine needed to process


func get_tier_color() -> Color:
	match tier:
		ItemTier.RAW: return Color(0.7, 0.7, 0.7)
		ItemTier.PROCESSED: return Color(0.4, 0.8, 0.4)
		ItemTier.REFINED: return Color(0.3, 0.5, 0.9)
		ItemTier.ENCHANTED: return Color(0.7, 0.4, 0.9)
	return Color.WHITE


func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color("#B2BEC3")
		Rarity.UNCOMMON: return Color("#00B894")
		Rarity.RARE: return Color("#0984E3")
		Rarity.EPIC: return Color("#6C5CE7")
		Rarity.LEGENDARY: return Color("#FDCB6E")
	return Color.WHITE


func get_category_color() -> Color:
	match category:
		ItemCategory.BOTANICAL: return Color("#00B894")
		ItemCategory.MINERAL: return Color("#74B9FF")
		ItemCategory.CREATURE: return Color("#E17055")
		ItemCategory.ELEMENTAL: return Color("#A29BFE")
		ItemCategory.FISH: return Color("#0984E3")
		ItemCategory.POTION: return Color("#6C5CE7")
	return Color.WHITE

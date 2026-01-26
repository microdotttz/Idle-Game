extends Resource
class_name MachineData
## MachineData - Defines properties of a workshop machine

enum MachineCategory {
	EXTRACTION,    # Raw -> Processed
	PROCESSING,    # Processed -> Refined
	REFINEMENT,    # Refined -> Enchanted
	BREWING,       # Makes potions
	STORAGE,       # Holds items
	SPECIALTY      # Special effects
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

@export var category: MachineCategory = MachineCategory.EXTRACTION
@export var unlock_cost: int = 0  # Gold to unlock/purchase
@export var unlock_reputation: int = 1  # Reputation tier required

# Processing
@export var process_time_multiplier: float = 1.0  # Speed modifier
@export var quality_bonus: float = 0.0  # Bonus to output quality
@export var efficiency_bonus: float = 0.0  # Chance for bonus output

# Capacity
@export var queue_size: int = 1  # How many items can be queued
@export var batch_size: int = 1  # How many items processed at once

# Accepted inputs (empty = accepts all for category)
@export var accepted_item_types: Array[String] = []

# Upgrade levels
@export var max_speed_level: int = 5
@export var max_efficiency_level: int = 5
@export var max_automation_level: int = 5

# Grid size for workshop placement
@export var grid_width: int = 1
@export var grid_height: int = 1


func get_upgrade_cost(upgrade_type: String, current_level: int) -> int:
	# Exponential upgrade cost
	var base_cost = unlock_cost
	return int(base_cost * pow(2, current_level))


func get_speed_at_level(level: int) -> float:
	# Each level = 25% faster
	return process_time_multiplier * (1.0 + 0.25 * (level - 1))


func get_efficiency_at_level(level: int) -> float:
	# Each level = 10% more bonus output chance
	return efficiency_bonus + 0.1 * (level - 1)


func get_category_color() -> Color:
	match category:
		MachineCategory.EXTRACTION: return Color("#00B894")
		MachineCategory.PROCESSING: return Color("#0984E3")
		MachineCategory.REFINEMENT: return Color("#6C5CE7")
		MachineCategory.BREWING: return Color("#E17055")
		MachineCategory.STORAGE: return Color("#636E72")
		MachineCategory.SPECIALTY: return Color("#FDCB6E")
	return Color.WHITE

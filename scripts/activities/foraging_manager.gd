extends Control
class_name ForagingManager
## Manages foraging activity

signal item_foraged(item_id: String, quantity: int)

enum ForagingState { IDLE, SEARCHING }

const FORAGING_AREAS = {
	"meadow": {
		"name": "Meadow",
		"unlock_cost": 0,
		"search_time": 15.0,
		"items": {
			"moonpetal": 0.3,
			"whisperroot": 0.2,
			"spring_water": 0.3,
			"common_fish": 0.1,  # Sometimes find fish in streams
			"rabbit_foot": 0.1   # Lucky find
		}
	},
	"forest_floor": {
		"name": "Forest Floor",
		"unlock_cost": 300,
		"search_time": 20.0,
		"items": {
			"whisperroot": 0.3,
			"shadowmoss": 0.2,
			"moonpetal": 0.2,
			"owl_feather": 0.15,
			"slime_glob": 0.15
		}
	},
	"riverbank": {
		"name": "Riverbank",
		"unlock_cost": 800,
		"search_time": 25.0,
		"items": {
			"spring_water": 0.3,
			"moonpetal": 0.2,
			"salt_rock": 0.2,
			"common_fish": 0.2,
			"eel": 0.1
		}
	},
	"mountain_slopes": {
		"name": "Mountain Slopes",
		"unlock_cost": 2500,
		"search_time": 35.0,
		"items": {
			"crystalstone": 0.25,
			"iron_ore": 0.25,
			"frostbloom": 0.2,
			"salt_rock": 0.15,
			"firefern": 0.15
		}
	},
	"ancient_ruins": {
		"name": "Ancient Ruins",
		"unlock_cost": 5000,
		"search_time": 45.0,
		"items": {
			"crystalstone": 0.2,
			"raw_mana": 0.2,
			"shadowmoss": 0.2,
			"moonpetal": 0.2,
			"whisperroot": 0.2
		}
	}
}

var current_state: ForagingState = ForagingState.IDLE
var current_location: String = "meadow"
var timer_id: String = ""
var found_items: Array[Dictionary] = []  # Items found in current search

@onready var location_list: VBoxContainer = $VBox/LocationScroll/LocationList
@onready var status_label: Label = $VBox/StatusPanel/StatusLabel
@onready var search_button: Button = $VBox/StatusPanel/SearchButton
@onready var collect_button: Button = $VBox/StatusPanel/CollectButton
@onready var progress_bar: ProgressBar = $VBox/StatusPanel/ProgressBar
@onready var loot_list: VBoxContainer = $VBox/StatusPanel/LootList
@onready var skill_label: Label = $VBox/SkillLabel


func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	search_button.pressed.connect(_on_search_pressed)
	collect_button.pressed.connect(_on_collect_pressed)

	_setup_locations()
	_update_display()


func _setup_locations() -> void:
	for child in location_list.get_children():
		child.queue_free()

	for loc_id in FORAGING_AREAS:
		var loc = FORAGING_AREAS[loc_id]
		var btn = Button.new()
		btn.toggle_mode = true

		var is_unlocked = loc["unlock_cost"] == 0 or GameManager.is_location_unlocked(loc_id)
		if is_unlocked:
			btn.text = loc["name"]
			if loc["unlock_cost"] == 0:
				GameManager.unlock_location(loc_id)
		else:
			btn.text = "%s (%dg)" % [loc["name"], loc["unlock_cost"]]
			btn.disabled = not GameManager.can_afford(loc["unlock_cost"])

		btn.button_pressed = (loc_id == current_location)
		btn.pressed.connect(_on_location_pressed.bind(loc_id, btn))
		location_list.add_child(btn)


func _on_location_pressed(loc_id: String, button: Button) -> void:
	var loc = FORAGING_AREAS[loc_id]

	if loc["unlock_cost"] > 0 and not GameManager.is_location_unlocked(loc_id):
		if GameManager.spend_gold(loc["unlock_cost"]):
			GameManager.unlock_location(loc_id)
			button.text = loc["name"]
		else:
			button.button_pressed = false
			return

	if current_state != ForagingState.IDLE or found_items.size() > 0:
		button.button_pressed = (loc_id == current_location)
		return

	current_location = loc_id
	_update_location_selection()
	_update_display()


func _update_location_selection() -> void:
	var buttons = location_list.get_children()
	var loc_ids = FORAGING_AREAS.keys()
	for i in range(min(buttons.size(), loc_ids.size())):
		if buttons[i] is Button:
			buttons[i].button_pressed = (loc_ids[i] == current_location)


func _on_search_pressed() -> void:
	if current_state != ForagingState.IDLE:
		return

	_start_searching()


func _start_searching() -> void:
	var loc = FORAGING_AREAS[current_location]

	var skill_bonus = GameManager.get_skill_level("foraging") * 0.02
	var search_time = loc["search_time"] * (1.0 - skill_bonus)

	current_state = ForagingState.SEARCHING
	timer_id = "foraging_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(timer_id, search_time, _on_search_complete)

	_update_display()


func _on_search_complete(_data: Variant = null) -> void:
	var loc = FORAGING_AREAS[current_location]
	found_items.clear()

	# Determine how many items found (2-5, affected by skill)
	var skill_level = GameManager.get_skill_level("foraging")
	var num_items = randi_range(2, 3) + int(skill_level / 10)

	# Roll for each item
	for i in range(num_items):
		var roll = randf()
		var cumulative = 0.0
		for item_id in loc["items"]:
			cumulative += loc["items"][item_id]
			if roll <= cumulative:
				# Check if already in found_items
				var existing = found_items.filter(func(x): return x["item_id"] == item_id)
				if existing.size() > 0:
					existing[0]["quantity"] += 1
				else:
					found_items.append({"item_id": item_id, "quantity": 1})
				break

	current_state = ForagingState.IDLE
	timer_id = ""

	_update_display()


func _on_collect_pressed() -> void:
	if found_items.is_empty():
		return

	# Add all found items to inventory
	for item in found_items:
		GameManager.add_item(item["item_id"], item["quantity"])
		GameManager.add_skill_xp("foraging", 3 * item["quantity"])
		item_foraged.emit(item["item_id"], item["quantity"])

	found_items.clear()
	_update_display()


func _on_tick() -> void:
	if current_state == ForagingState.SEARCHING:
		_update_display()


func _update_display() -> void:
	var loc = FORAGING_AREAS[current_location]

	skill_label.text = "Foraging Skill: Lv.%d" % GameManager.get_skill_level("foraging")

	# Clear loot list
	for child in loot_list.get_children():
		child.queue_free()

	if current_state == ForagingState.SEARCHING:
		var progress = TimeManager.get_timer_progress(timer_id)
		var remaining = TimeManager.get_timer_remaining(timer_id)
		status_label.text = "Searching %s...\n%s" % [loc["name"], TimeManager.format_time(remaining)]
		search_button.visible = true
		search_button.disabled = true
		collect_button.visible = false
		progress_bar.visible = true
		progress_bar.value = progress * 100

	elif found_items.size() > 0:
		status_label.text = "Found items! Tap Collect to gather:"
		search_button.visible = false
		collect_button.visible = true
		collect_button.disabled = false
		progress_bar.visible = false

		# Show found items
		for item in found_items:
			var item_data = ItemDatabase.get_item(item["item_id"])
			var item_name = item_data.display_name if item_data else item["item_id"]
			var label = Label.new()
			label.text = "  • %dx %s" % [item["quantity"], item_name]
			loot_list.add_child(label)

	else:
		status_label.text = "Location: %s\nReady to search" % loc["name"]
		search_button.visible = true
		search_button.disabled = false
		collect_button.visible = false
		progress_bar.visible = false

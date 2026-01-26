extends Control
class_name HuntingManager
## Manages hunting activity

signal creature_hunted(item_id: String, quantity: int)

enum HuntingState { IDLE, TRACKING, HUNTING }

const HUNTING_GROUNDS = {
	"forest_edge": {
		"name": "Forest Edge",
		"unlock_cost": 0,
		"track_time_min": 10.0,
		"track_time_max": 20.0,
		"creatures": {
			"rabbit_foot": {"name": "Rabbit", "chance": 0.5, "difficulty": 1},
			"owl_feather": {"name": "Owl", "chance": 0.3, "difficulty": 2},
			"wolf_fang": {"name": "Wolf", "chance": 0.2, "difficulty": 3}
		}
	},
	"deep_woods": {
		"name": "Deep Woods",
		"unlock_cost": 1000,
		"track_time_min": 15.0,
		"track_time_max": 30.0,
		"creatures": {
			"wolf_fang": {"name": "Wolf", "chance": 0.4, "difficulty": 3},
			"owl_feather": {"name": "Owl", "chance": 0.3, "difficulty": 2},
			"slime_glob": {"name": "Forest Slime", "chance": 0.3, "difficulty": 1}
		}
	},
	"swamplands": {
		"name": "Swamplands",
		"unlock_cost": 3000,
		"track_time_min": 20.0,
		"track_time_max": 40.0,
		"creatures": {
			"slime_glob": {"name": "Swamp Slime", "chance": 0.5, "difficulty": 1},
			"wolf_fang": {"name": "Swamp Wolf", "chance": 0.3, "difficulty": 3},
			"owl_feather": {"name": "Night Heron", "chance": 0.2, "difficulty": 2}
		}
	}
}

var current_state: HuntingState = HuntingState.IDLE
var current_location: String = "forest_edge"
var current_creature: Dictionary = {}
var current_loot_id: String = ""
var timer_id: String = ""

@onready var location_list: VBoxContainer = $VBox/LocationScroll/LocationList
@onready var status_label: Label = $VBox/StatusPanel/StatusLabel
@onready var track_button: Button = $VBox/StatusPanel/TrackButton
@onready var hunt_button: Button = $VBox/StatusPanel/HuntButton
@onready var progress_bar: ProgressBar = $VBox/StatusPanel/ProgressBar
@onready var skill_label: Label = $VBox/SkillLabel


func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	track_button.pressed.connect(_on_track_pressed)
	hunt_button.pressed.connect(_on_hunt_pressed)

	_setup_locations()
	_update_display()


func _setup_locations() -> void:
	for child in location_list.get_children():
		child.queue_free()

	for loc_id in HUNTING_GROUNDS:
		var loc = HUNTING_GROUNDS[loc_id]
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
	var loc = HUNTING_GROUNDS[loc_id]

	if loc["unlock_cost"] > 0 and not GameManager.is_location_unlocked(loc_id):
		if GameManager.spend_gold(loc["unlock_cost"]):
			GameManager.unlock_location(loc_id)
			button.text = loc["name"]
		else:
			button.button_pressed = false
			return

	if current_state != HuntingState.IDLE:
		button.button_pressed = (loc_id == current_location)
		return

	current_location = loc_id
	_update_location_selection()
	_update_display()


func _update_location_selection() -> void:
	var buttons = location_list.get_children()
	var loc_ids = HUNTING_GROUNDS.keys()
	for i in range(min(buttons.size(), loc_ids.size())):
		if buttons[i] is Button:
			buttons[i].button_pressed = (loc_ids[i] == current_location)


func _on_track_pressed() -> void:
	if current_state != HuntingState.IDLE:
		return

	_start_tracking()


func _start_tracking() -> void:
	var loc = HUNTING_GROUNDS[current_location]

	var skill_bonus = GameManager.get_skill_level("hunting") * 0.02
	var track_time = randf_range(loc["track_time_min"], loc["track_time_max"])
	track_time *= (1.0 - skill_bonus)

	current_state = HuntingState.TRACKING
	timer_id = "hunting_track_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(timer_id, track_time, _on_creature_found)

	_update_display()


func _on_creature_found(_data: Variant = null) -> void:
	var loc = HUNTING_GROUNDS[current_location]

	# Determine creature based on chances
	var roll = randf()
	var cumulative = 0.0
	for loot_id in loc["creatures"]:
		var creature = loc["creatures"][loot_id]
		cumulative += creature["chance"]
		if roll <= cumulative:
			current_creature = creature
			current_loot_id = loot_id
			break

	if current_creature.is_empty():
		# Fallback to first creature
		var first_loot_id = loc["creatures"].keys()[0]
		current_creature = loc["creatures"][first_loot_id]
		current_loot_id = first_loot_id

	current_state = HuntingState.HUNTING
	_update_display()


func _on_hunt_pressed() -> void:
	if current_state != HuntingState.HUNTING:
		return

	_attempt_hunt()


func _attempt_hunt() -> void:
	var skill_level = GameManager.get_skill_level("hunting")
	var difficulty = current_creature.get("difficulty", 1)

	# Success chance based on skill vs difficulty
	var base_chance = 0.5
	var skill_bonus = (skill_level - difficulty) * 0.1
	var success_chance = clamp(base_chance + skill_bonus, 0.2, 0.95)

	if randf() < success_chance:
		# Success!
		var quantity = 1
		if randf() < 0.2:  # 20% chance for bonus loot
			quantity = 2

		GameManager.add_item(current_loot_id, quantity)
		GameManager.stats["creatures_hunted"] += 1
		GameManager.add_skill_xp("hunting", 15)

		creature_hunted.emit(current_loot_id, quantity)

		var item_data = ItemDatabase.get_item(current_loot_id)
		var item_name = item_data.display_name if item_data else current_loot_id
		status_label.text = "Hunt successful!\nObtained: %dx %s" % [quantity, item_name]
	else:
		# Failed
		status_label.text = "The %s escaped!" % current_creature["name"]
		GameManager.add_skill_xp("hunting", 5)  # Still get some XP

	# Reset
	current_state = HuntingState.IDLE
	current_creature = {}
	current_loot_id = ""
	timer_id = ""

	_update_display()


func _on_tick() -> void:
	if current_state == HuntingState.TRACKING:
		_update_display()


func _update_display() -> void:
	var loc = HUNTING_GROUNDS[current_location]

	skill_label.text = "Hunting Skill: Lv.%d" % GameManager.get_skill_level("hunting")

	match current_state:
		HuntingState.IDLE:
			status_label.text = "Location: %s\nReady to track" % loc["name"]
			track_button.visible = true
			track_button.disabled = false
			hunt_button.visible = false
			progress_bar.visible = false

		HuntingState.TRACKING:
			var progress = TimeManager.get_timer_progress(timer_id)
			var remaining = TimeManager.get_timer_remaining(timer_id)
			status_label.text = "Tracking...\n%s" % TimeManager.format_time(remaining)
			track_button.visible = true
			track_button.disabled = true
			hunt_button.visible = false
			progress_bar.visible = true
			progress_bar.value = progress * 100

		HuntingState.HUNTING:
			status_label.text = "Found: %s\nDifficulty: %d\nTap Hunt to attack!" % [
				current_creature["name"],
				current_creature["difficulty"]
			]
			track_button.visible = false
			hunt_button.visible = true
			hunt_button.disabled = false
			progress_bar.visible = false

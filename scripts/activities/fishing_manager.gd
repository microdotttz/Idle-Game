extends Control
class_name FishingManager
## Manages fishing activity

signal fish_caught(fish_id: String, quantity: int)

enum FishingState { IDLE, WAITING, CATCH_READY, REELING }

# Fishing locations
const LOCATIONS = {
	"village_pond": {
		"name": "Village Pond",
		"unlock_cost": 0,
		"wait_time_min": 5.0,
		"wait_time_max": 15.0,
		"fish": ["common_fish"],
		"rare_fish": [],
		"rare_chance": 0.0
	},
	"forest_stream": {
		"name": "Forest Stream",
		"unlock_cost": 500,
		"wait_time_min": 8.0,
		"wait_time_max": 20.0,
		"fish": ["common_fish", "trout"],
		"rare_fish": ["spirit_fish"],
		"rare_chance": 0.05
	},
	"river_delta": {
		"name": "River Delta",
		"unlock_cost": 2000,
		"wait_time_min": 10.0,
		"wait_time_max": 25.0,
		"fish": ["trout", "eel"],
		"rare_fish": ["spirit_fish"],
		"rare_chance": 0.1
	},
	"ocean_pier": {
		"name": "Ocean Pier",
		"unlock_cost": 5000,
		"wait_time_min": 15.0,
		"wait_time_max": 35.0,
		"fish": ["common_fish", "eel"],
		"rare_fish": ["spirit_fish"],
		"rare_chance": 0.15
	}
}

var current_state: FishingState = FishingState.IDLE
var current_location: String = "village_pond"
var current_fish: String = ""
var timer_id: String = ""
var catch_window_timer_id: String = ""

@onready var location_list: VBoxContainer = $VBox/LocationScroll/LocationList
@onready var status_label: Label = $VBox/StatusPanel/StatusLabel
@onready var cast_button: Button = $VBox/StatusPanel/CastButton
@onready var catch_button: Button = $VBox/StatusPanel/CatchButton
@onready var progress_bar: ProgressBar = $VBox/StatusPanel/ProgressBar
@onready var skill_label: Label = $VBox/SkillLabel


func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	cast_button.pressed.connect(_on_cast_pressed)
	catch_button.pressed.connect(_on_catch_pressed)

	_setup_locations()
	_update_display()


func _setup_locations() -> void:
	for child in location_list.get_children():
		child.queue_free()

	for loc_id in LOCATIONS:
		var loc = LOCATIONS[loc_id]
		var btn = Button.new()
		btn.toggle_mode = true

		if GameManager.is_location_unlocked(loc_id):
			btn.text = loc["name"]
		else:
			btn.text = "%s (%dg)" % [loc["name"], loc["unlock_cost"]]
			btn.disabled = not GameManager.can_afford(loc["unlock_cost"])

		btn.button_pressed = (loc_id == current_location)
		btn.pressed.connect(_on_location_pressed.bind(loc_id, btn))
		location_list.add_child(btn)


func _on_location_pressed(loc_id: String, button: Button) -> void:
	if not GameManager.is_location_unlocked(loc_id):
		var loc = LOCATIONS[loc_id]
		if GameManager.spend_gold(loc["unlock_cost"]):
			GameManager.unlock_location(loc_id)
			button.text = loc["name"]
		else:
			button.button_pressed = false
			return

	# Can't change location while fishing
	if current_state != FishingState.IDLE:
		button.button_pressed = (loc_id == current_location)
		return

	current_location = loc_id
	_update_location_selection()
	_update_display()


func _update_location_selection() -> void:
	var buttons = location_list.get_children()
	var loc_ids = LOCATIONS.keys()
	for i in range(min(buttons.size(), loc_ids.size())):
		if buttons[i] is Button:
			buttons[i].button_pressed = (loc_ids[i] == current_location)


func _on_cast_pressed() -> void:
	if current_state != FishingState.IDLE:
		return

	_start_fishing()


func _start_fishing() -> void:
	var loc = LOCATIONS[current_location]

	# Calculate wait time (affected by skill)
	var skill_bonus = GameManager.get_skill_level("fishing") * 0.02  # 2% faster per level
	var wait_time = randf_range(loc["wait_time_min"], loc["wait_time_max"])
	wait_time *= (1.0 - skill_bonus)

	current_state = FishingState.WAITING
	timer_id = "fishing_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(timer_id, wait_time, _on_fish_bite)

	_update_display()


func _on_fish_bite(_data: Variant = null) -> void:
	current_state = FishingState.CATCH_READY

	# Determine which fish
	var loc = LOCATIONS[current_location]
	var skill_bonus = GameManager.get_skill_level("fishing") * 0.01

	if randf() < loc["rare_chance"] + skill_bonus and loc["rare_fish"].size() > 0:
		current_fish = loc["rare_fish"][randi() % loc["rare_fish"].size()]
	else:
		current_fish = loc["fish"][randi() % loc["fish"].size()]

	# Start catch window timer (must click within this time)
	catch_window_timer_id = "catch_window_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(catch_window_timer_id, 3.0, _on_catch_window_expired)

	_update_display()


func _on_catch_window_expired(_data: Variant = null) -> void:
	if current_state == FishingState.CATCH_READY:
		# Missed the fish
		current_state = FishingState.IDLE
		current_fish = ""
		status_label.text = "The fish got away!"
		_update_display()


func _on_catch_pressed() -> void:
	if current_state != FishingState.CATCH_READY:
		return

	# Cancel catch window timer
	TimeManager.cancel_timer(catch_window_timer_id)

	# Catch the fish!
	current_state = FishingState.REELING
	_catch_fish()


func _catch_fish() -> void:
	# Add fish to inventory
	GameManager.add_item(current_fish, 1)
	GameManager.stats["fish_caught"] += 1
	GameManager.add_skill_xp("fishing", 10)

	var item_data = ItemDatabase.get_item(current_fish)
	var fish_name = item_data.display_name if item_data else current_fish

	fish_caught.emit(current_fish, 1)
	status_label.text = "Caught: %s!" % fish_name

	# Reset
	current_state = FishingState.IDLE
	current_fish = ""
	timer_id = ""

	_update_display()


func _on_tick() -> void:
	if current_state == FishingState.WAITING or current_state == FishingState.CATCH_READY:
		_update_display()


func _update_display() -> void:
	var loc = LOCATIONS[current_location]

	skill_label.text = "Fishing Skill: Lv.%d" % GameManager.get_skill_level("fishing")

	match current_state:
		FishingState.IDLE:
			status_label.text = "Location: %s\nReady to fish" % loc["name"]
			cast_button.visible = true
			cast_button.disabled = false
			catch_button.visible = false
			progress_bar.visible = false

		FishingState.WAITING:
			var progress = TimeManager.get_timer_progress(timer_id)
			var remaining = TimeManager.get_timer_remaining(timer_id)
			status_label.text = "Waiting for a bite...\n%s" % TimeManager.format_time(remaining)
			cast_button.visible = true
			cast_button.disabled = true
			catch_button.visible = false
			progress_bar.visible = true
			progress_bar.value = progress * 100

		FishingState.CATCH_READY:
			var remaining = TimeManager.get_timer_remaining(catch_window_timer_id)
			status_label.text = "FISH ON! TAP NOW!\n%.1fs" % remaining
			cast_button.visible = false
			catch_button.visible = true
			catch_button.disabled = false
			progress_bar.visible = true
			progress_bar.value = 100
			progress_bar.modulate = Color.GREEN

		FishingState.REELING:
			cast_button.visible = false
			catch_button.visible = false
			progress_bar.visible = false

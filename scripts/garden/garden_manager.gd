extends Control
class_name GardenManager
## Manages the garden view - plant plots and growing

signal plant_harvested(item_id: String, quantity: int)
signal plant_planted(plot_index: int, seed_id: String)

const STARTING_PLOTS = 4
const MAX_PLOTS = 16

# Plot data: index -> { "seed_id": String, "timer_id": String, "planted_at": float }
var plots: Array[Dictionary] = []
var unlocked_plots: int = STARTING_PLOTS

var selected_seed: String = ""

@onready var plot_grid: GridContainer = $MainContent/PlotArea/PlotGrid
@onready var seed_list: HBoxContainer = $MainContent/SeedPanel/SeedScroll/SeedList
@onready var info_label: Label = $MainContent/InfoLabel

var plot_scene: PackedScene


func _ready() -> void:
	plot_scene = preload("res://scenes/ui/components/garden_plot.tscn")
	TimeManager.tick.connect(_on_tick)

	_setup_plots()
	_setup_seed_list()
	_update_display()


func _setup_plots() -> void:
	# Initialize plot data
	for i in range(MAX_PLOTS):
		plots.append({
			"seed_id": "",
			"timer_id": "",
			"planted_at": 0.0,
			"grow_time": 0.0
		})

	# Create plot UI
	for i in range(MAX_PLOTS):
		var plot = _create_plot(i)
		plot_grid.add_child(plot)


func _create_plot(index: int) -> Control:
	var plot = PanelContainer.new()
	plot.custom_minimum_size = Vector2(80, 100)
	plot.name = "Plot_%d" % index

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	plot.add_child(vbox)

	# Plant icon
	var icon = TextureRect.new()
	icon.name = "PlantIcon"
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(icon)

	# Progress bar
	var progress = ProgressBar.new()
	progress.name = "GrowthBar"
	progress.custom_minimum_size = Vector2(60, 10)
	progress.show_percentage = false
	progress.visible = false
	vbox.add_child(progress)

	# Status label
	var label = Label.new()
	label.name = "StatusLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(label)

	# Harvest/Plant button
	var btn = Button.new()
	btn.name = "ActionButton"
	btn.text = "Plant"
	btn.pressed.connect(_on_plot_action.bind(index))
	vbox.add_child(btn)

	# Style based on unlock status
	_update_plot_style(plot, index)

	return plot


func _update_plot_style(plot: PanelContainer, index: int) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	if index < unlocked_plots:
		style.bg_color = Color("#8B7355")  # Brown soil
		style.border_color = Color("#5D4E37")
	else:
		style.bg_color = Color("#4A4A4A")  # Locked
		style.border_color = Color("#2D2D2D")

	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	plot.add_theme_stylebox_override("panel", style)


func _setup_seed_list() -> void:
	# Clear existing
	for child in seed_list.get_children():
		child.queue_free()

	# Add plantable items from inventory
	var plantable_items = _get_plantable_items()

	for item_id in plantable_items:
		var item_data = ItemDatabase.get_item(item_id)
		if not item_data:
			continue

		var btn = Button.new()
		btn.text = "%s (%d)" % [item_data.display_name, GameManager.get_item_count(item_id)]
		btn.toggle_mode = true
		btn.pressed.connect(_on_seed_selected.bind(item_id, btn))
		seed_list.add_child(btn)


func _get_plantable_items() -> Array[String]:
	var plantable: Array[String] = []

	# Items with grow_time are plantable
	for item_id in GameManager.inventory:
		var item_data = ItemDatabase.get_item(item_id)
		if item_data and item_data.grow_time > 0:
			plantable.append(item_id)

	# Also add seeds player might have
	var seeds = ["moonpetal", "firefern", "whisperroot", "frostbloom", "shadowmoss"]
	for seed_id in seeds:
		if GameManager.has_item(seed_id) and seed_id not in plantable:
			plantable.append(seed_id)

	return plantable


func _on_seed_selected(seed_id: String, button: Button) -> void:
	# Deselect others
	for child in seed_list.get_children():
		if child is Button and child != button:
			child.button_pressed = false

	if button.button_pressed:
		selected_seed = seed_id
		info_label.text = "Selected: %s - Tap an empty plot to plant" % ItemDatabase.get_item(seed_id).display_name
	else:
		selected_seed = ""
		info_label.text = "Select a seed to plant"


func _on_plot_action(plot_index: int) -> void:
	if plot_index >= unlocked_plots:
		# Try to unlock
		_try_unlock_plot(plot_index)
		return

	var plot_data = plots[plot_index]

	if plot_data["seed_id"] == "":
		# Plant
		_plant_seed(plot_index)
	elif _is_ready_to_harvest(plot_index):
		# Harvest
		_harvest_plot(plot_index)
	# else: still growing, do nothing


func _try_unlock_plot(plot_index: int) -> void:
	var cost = 100 * (plot_index - STARTING_PLOTS + 1)
	if GameManager.spend_gold(cost):
		unlocked_plots = plot_index + 1
		var plot = plot_grid.get_child(plot_index)
		_update_plot_style(plot, plot_index)
		_update_plot_display(plot_index)


func _plant_seed(plot_index: int) -> void:
	if selected_seed == "" or not GameManager.has_item(selected_seed):
		return

	var item_data = ItemDatabase.get_item(selected_seed)
	if not item_data:
		return

	# Remove seed from inventory
	GameManager.remove_item(selected_seed, 1)

	# Start growing
	var plot_data = plots[plot_index]
	plot_data["seed_id"] = selected_seed
	plot_data["planted_at"] = Time.get_unix_time_from_system()
	plot_data["grow_time"] = item_data.grow_time

	# Start timer
	plot_data["timer_id"] = "garden_plot_%d_%d" % [plot_index, Time.get_ticks_msec()]
	TimeManager.start_timer(plot_data["timer_id"], item_data.grow_time, _on_growth_complete.bind(plot_index))

	plant_planted.emit(plot_index, selected_seed)
	GameManager.add_skill_xp("herbalism", 1)

	_update_plot_display(plot_index)
	_setup_seed_list()  # Refresh seed counts


func _on_growth_complete(plot_index: int) -> void:
	_update_plot_display(plot_index)


func _is_ready_to_harvest(plot_index: int) -> bool:
	var plot_data = plots[plot_index]
	if plot_data["seed_id"] == "" or plot_data["timer_id"] == "":
		return false
	return not TimeManager.is_timer_active(plot_data["timer_id"])


func _harvest_plot(plot_index: int) -> void:
	var plot_data = plots[plot_index]
	var seed_id = plot_data["seed_id"]

	if seed_id == "":
		return

	# Calculate yield (base 1-2, bonus from herbalism)
	var base_yield = randi_range(1, 2)
	var skill_bonus = GameManager.get_skill_level("herbalism") / 10
	var total_yield = base_yield + skill_bonus

	# Add to inventory
	GameManager.add_item(seed_id, total_yield)
	GameManager.add_skill_xp("herbalism", 5)

	plant_harvested.emit(seed_id, total_yield)

	# Reset plot
	plot_data["seed_id"] = ""
	plot_data["timer_id"] = ""
	plot_data["planted_at"] = 0.0
	plot_data["grow_time"] = 0.0

	_update_plot_display(plot_index)
	_setup_seed_list()


func _on_tick() -> void:
	# Update growing plots
	for i in range(unlocked_plots):
		if plots[i]["seed_id"] != "" and plots[i]["timer_id"] != "":
			_update_plot_display(i)


func _update_display() -> void:
	for i in range(MAX_PLOTS):
		_update_plot_display(i)


func _update_plot_display(plot_index: int) -> void:
	var plot = plot_grid.get_child(plot_index) as PanelContainer
	if not plot:
		return

	var vbox = plot.get_child(0) as VBoxContainer
	var icon = vbox.get_node("PlantIcon") as TextureRect
	var progress = vbox.get_node("GrowthBar") as ProgressBar
	var status = vbox.get_node("StatusLabel") as Label
	var btn = vbox.get_node("ActionButton") as Button

	if plot_index >= unlocked_plots:
		# Locked
		var cost = 100 * (plot_index - STARTING_PLOTS + 1)
		icon.modulate = Color(0.3, 0.3, 0.3)
		progress.visible = false
		status.text = "Locked"
		btn.text = "Unlock (%dg)" % cost
		btn.disabled = not GameManager.can_afford(cost)
		return

	var plot_data = plots[plot_index]

	if plot_data["seed_id"] == "":
		# Empty plot
		icon.modulate = Color(0.6, 0.5, 0.4)
		progress.visible = false
		status.text = "Empty"
		btn.text = "Plant"
		btn.disabled = selected_seed == ""
	elif _is_ready_to_harvest(plot_index):
		# Ready to harvest
		var item_data = ItemDatabase.get_item(plot_data["seed_id"])
		icon.modulate = item_data.get_category_color() if item_data else Color.GREEN
		progress.visible = false
		status.text = "Ready!"
		btn.text = "Harvest"
		btn.disabled = false
	else:
		# Growing
		var item_data = ItemDatabase.get_item(plot_data["seed_id"])
		icon.modulate = item_data.get_category_color().darkened(0.3) if item_data else Color.GREEN
		progress.visible = true

		var grow_progress = TimeManager.get_timer_progress(plot_data["timer_id"])
		progress.value = grow_progress * 100

		var remaining = TimeManager.get_timer_remaining(plot_data["timer_id"])
		status.text = TimeManager.format_time(remaining)
		btn.text = "Growing..."
		btn.disabled = true


# Save/Load
func get_save_data() -> Dictionary:
	var plot_save_data = []
	for plot_data in plots:
		plot_save_data.append({
			"seed_id": plot_data["seed_id"],
			"planted_at": plot_data["planted_at"],
			"grow_time": plot_data["grow_time"]
		})
	return {
		"plots": plot_save_data,
		"unlocked_plots": unlocked_plots
	}


func load_save_data(data: Dictionary) -> void:
	unlocked_plots = data.get("unlocked_plots", STARTING_PLOTS)
	var plot_save_data = data.get("plots", [])

	for i in range(min(plot_save_data.size(), plots.size())):
		var saved = plot_save_data[i]
		plots[i]["seed_id"] = saved.get("seed_id", "")
		plots[i]["planted_at"] = saved.get("planted_at", 0.0)
		plots[i]["grow_time"] = saved.get("grow_time", 0.0)

		# Restart timer if still growing
		if plots[i]["seed_id"] != "" and plots[i]["grow_time"] > 0:
			var elapsed = Time.get_unix_time_from_system() - plots[i]["planted_at"]
			var remaining = plots[i]["grow_time"] - elapsed
			if remaining > 0:
				plots[i]["timer_id"] = "garden_plot_%d_%d" % [i, Time.get_ticks_msec()]
				TimeManager.start_timer(plots[i]["timer_id"], remaining, _on_growth_complete.bind(i))
			else:
				plots[i]["timer_id"] = "complete"  # Mark as harvestable

	_update_display()

extends Control
class_name WorkshopManager
## Manages the workshop view - machine grid, placement, and processing

signal machine_placed(machine_id: String, grid_pos: Vector2i)
signal machine_removed(grid_pos: Vector2i)
signal item_processed(input_item: String, output_item: String)

const GRID_SIZE = Vector2i(5, 5)  # 5x5 grid to start
const CELL_SIZE = Vector2(64, 64)

# Grid data: Vector2i position -> machine instance
var grid: Dictionary = {}
var selected_machine_type: String = ""

@onready var grid_container: Control = $MainContent/WorkshopArea/GridContainer
@onready var machine_list: HBoxContainer = $MainContent/MachinePanel/MachineVBox/MachineScroll/MachineList
@onready var info_panel: PanelContainer = $MainContent/InfoPanel
@onready var info_label: Label = $MainContent/InfoPanel/InfoContent/InfoLabel
@onready var process_button: Button = $MainContent/InfoPanel/InfoContent/ProcessButton

var machine_slot_scene: PackedScene
var selected_grid_pos: Vector2i = Vector2i(-1, -1)
var recipe_container: VBoxContainer


func _ready() -> void:
	machine_slot_scene = preload("res://scenes/ui/components/machine_slot.tscn")

	# Hide legacy process button — replaced by recipe selection list
	process_button.visible = false

	# Create recipe list container in info panel
	var info_content = $MainContent/InfoPanel/InfoContent
	recipe_container = VBoxContainer.new()
	recipe_container.name = "RecipeContainer"
	recipe_container.add_theme_constant_override("separation", 4)
	info_content.add_child(recipe_container)

	_setup_grid()
	_setup_machine_list()
	_place_starting_machines()
	_update_display()


func _setup_grid() -> void:
	# Create grid cells
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell = _create_grid_cell(Vector2i(x, y))
			grid_container.add_child(cell)


func _create_grid_cell(grid_pos: Vector2i) -> Control:
	var cell = PanelContainer.new()
	cell.custom_minimum_size = CELL_SIZE
	cell.name = "Cell_%d_%d" % [grid_pos.x, grid_pos.y]

	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.88, 0.85)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.7, 0.68, 0.65)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	cell.add_theme_stylebox_override("panel", style)

	# Content container
	var content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_child(content)

	# Icon placeholder
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(40, 40)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content.add_child(icon)

	# Progress bar
	var progress = ProgressBar.new()
	progress.name = "ProgressBar"
	progress.custom_minimum_size = Vector2(50, 8)
	progress.show_percentage = false
	progress.visible = false
	content.add_child(progress)

	# Make clickable
	cell.gui_input.connect(_on_cell_input.bind(grid_pos))

	return cell


func _on_cell_input(event: InputEvent, grid_pos: Vector2i) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_cell_clicked(grid_pos)


func _on_cell_clicked(grid_pos: Vector2i) -> void:
	if selected_machine_type != "":
		# Place machine
		if _can_place_machine(grid_pos, selected_machine_type):
			_place_machine(grid_pos, selected_machine_type)
			selected_machine_type = ""
			_update_machine_list_selection()
	else:
		# Select cell
		selected_grid_pos = grid_pos
		_update_info_panel()
	_update_display()


func _can_place_machine(grid_pos: Vector2i, machine_id: String) -> bool:
	if grid.has(grid_pos):
		return false
	if not GameManager.is_machine_unlocked(machine_id):
		return false
	return true


func _place_machine(grid_pos: Vector2i, machine_id: String) -> void:
	var machine_data = ItemDatabase.get_machine(machine_id)
	if not machine_data:
		return

	# Create machine instance data
	var machine_instance = {
		"machine_id": machine_id,
		"data": machine_data,
		"state": "idle",  # idle, processing, complete
		"current_recipe": "",
		"current_input": "",
		"current_output": "",
		"speed_level": 1,
		"efficiency_level": 1,
		"automation_level": 1,
		"timer_id": ""
	}

	grid[grid_pos] = machine_instance
	machine_placed.emit(machine_id, grid_pos)
	_update_cell_display(grid_pos)


func _remove_machine(grid_pos: Vector2i) -> void:
	if not grid.has(grid_pos):
		return

	var machine = grid[grid_pos]
	if machine["timer_id"] != "":
		TimeManager.cancel_timer(machine["timer_id"])

	grid.erase(grid_pos)
	machine_removed.emit(grid_pos)
	_update_cell_display(grid_pos)


func _place_starting_machines() -> void:
	# Place starting machines
	_place_machine(Vector2i(0, 2), "mortar_pestle")
	_place_machine(Vector2i(2, 2), "basic_cauldron")


func _setup_machine_list() -> void:
	# Clear existing
	for child in machine_list.get_children():
		child.queue_free()

	# Add unlocked machines
	var machines = ItemDatabase.get_all_machines()
	for machine_id in machines:
		var machine_data = machines[machine_id]
		var btn = Button.new()
		btn.text = machine_data.display_name
		btn.toggle_mode = true

		if not GameManager.is_machine_unlocked(machine_id):
			btn.text += " (%dg)" % machine_data.unlock_cost
			btn.disabled = not GameManager.can_afford(machine_data.unlock_cost)

		btn.pressed.connect(_on_machine_list_pressed.bind(machine_id, btn))
		machine_list.add_child(btn)


func _on_machine_list_pressed(machine_id: String, button: Button) -> void:
	var machine_data = ItemDatabase.get_machine(machine_id)

	if not GameManager.is_machine_unlocked(machine_id):
		# Try to unlock
		if GameManager.spend_gold(machine_data.unlock_cost):
			GameManager.unlock_machine(machine_id)
			button.text = machine_data.display_name
			button.disabled = false
		else:
			button.button_pressed = false
			return

	if button.button_pressed:
		selected_machine_type = machine_id
	else:
		selected_machine_type = ""

	_update_machine_list_selection()


func _update_machine_list_selection() -> void:
	for child in machine_list.get_children():
		if child is Button:
			var machine_id = child.text.split(" (")[0].to_lower().replace(" ", "_")
			child.button_pressed = (selected_machine_type != "" and child.text.begins_with(ItemDatabase.get_machine(selected_machine_type).display_name if selected_machine_type != "" else ""))


func _update_info_panel() -> void:
	if selected_grid_pos == Vector2i(-1, -1) or not grid.has(selected_grid_pos):
		info_panel.visible = false
		return

	info_panel.visible = true
	var machine = grid[selected_grid_pos]
	var data = machine["data"] as MachineData

	var info_text = "%s\n" % data.display_name
	info_text += "State: %s" % machine["state"].capitalize()

	if machine["state"] == "processing":
		var recipe = ItemDatabase.get_recipe(machine["current_recipe"])
		if recipe:
			info_text += "\nCrafting: %s" % recipe.display_name
		var remaining = TimeManager.get_timer_remaining(machine["timer_id"])
		if remaining > 0:
			info_text += "\nTime left: %s" % TimeManager.format_time(remaining)

	info_label.text = info_text
	_update_recipe_list(machine)


func _update_recipe_list(machine: Dictionary) -> void:
	# Clear existing recipe buttons
	for child in recipe_container.get_children():
		child.queue_free()

	# Only show recipes when machine is idle
	if machine["state"] != "idle":
		return

	# Get compatible recipes for this machine
	var compatible_recipes = ItemDatabase.get_recipes_for_machine(machine["machine_id"])

	if compatible_recipes.is_empty():
		var label = Label.new()
		label.text = "No recipes for this machine"
		label.add_theme_font_size_override("font_size", 12)
		recipe_container.add_child(label)
		return

	var header = Label.new()
	header.text = "Recipes:"
	header.add_theme_font_size_override("font_size", 13)
	recipe_container.add_child(header)

	for recipe in compatible_recipes:
		if not GameManager.is_recipe_unlocked(recipe.id):
			continue

		var skill_level = GameManager.get_skill_level("brewing")
		var can_craft = recipe.can_craft(GameManager.inventory, skill_level)

		# Build ingredient summary
		var ing_parts: PackedStringArray = []
		for ing in recipe.ingredients:
			var item_data = ItemDatabase.get_item(ing["item_id"])
			var item_name = item_data.display_name if item_data else ing["item_id"]
			var have = GameManager.get_item_count(ing["item_id"])
			var need = ing["amount"]
			ing_parts.append("%s %d/%d" % [item_name, have, need])

		var btn = Button.new()
		btn.text = "%s (%ds) - %s" % [recipe.display_name, int(recipe.craft_time), ", ".join(ing_parts)]
		btn.disabled = not can_craft
		btn.pressed.connect(_on_recipe_selected.bind(recipe.id))
		btn.custom_minimum_size.y = 36
		recipe_container.add_child(btn)


func _on_recipe_selected(recipe_id: String) -> void:
	if selected_grid_pos == Vector2i(-1, -1) or not grid.has(selected_grid_pos):
		return
	_start_processing(selected_grid_pos, recipe_id)


func _start_processing(grid_pos: Vector2i, recipe_id: String) -> void:
	if not grid.has(grid_pos):
		return

	var recipe = ItemDatabase.get_recipe(recipe_id)
	if not recipe:
		return

	var machine = grid[grid_pos]

	# Validate machine is compatible with recipe
	if not ItemDatabase._is_machine_compatible(machine["machine_id"], recipe.required_machine):
		return

	# Check ingredients and skill level
	var skill_level = GameManager.get_skill_level("brewing")
	if not recipe.can_craft(GameManager.inventory, skill_level):
		return

	# Consume ingredients
	recipe.consume_ingredients(GameManager.inventory)

	# Start timer
	machine["state"] = "processing"
	machine["current_recipe"] = recipe_id
	machine["current_input"] = recipe_id
	machine["current_output"] = recipe.output_item_id
	machine["timer_id"] = "machine_%d_%d_%d" % [grid_pos.x, grid_pos.y, Time.get_ticks_msec()]

	var process_time = recipe.craft_time / machine["data"].get_speed_at_level(machine["speed_level"])

	TimeManager.start_timer(machine["timer_id"], process_time, _on_processing_complete.bind(grid_pos))
	_update_cell_display(grid_pos)
	_update_info_panel()


func _on_processing_complete(grid_pos: Vector2i) -> void:
	if not grid.has(grid_pos):
		return

	var machine = grid[grid_pos]
	machine["state"] = "complete"

	# Determine output amount from recipe
	var output_amount = 1
	var recipe = ItemDatabase.get_recipe(machine["current_recipe"])
	if recipe:
		output_amount = recipe.output_amount

	# Apply efficiency bonus
	var efficiency = machine["data"].get_efficiency_at_level(machine["efficiency_level"])
	if randf() < efficiency:
		output_amount += 1

	# Add output to inventory
	GameManager.add_item(machine["current_output"], output_amount)

	# Track correct stat based on output item category
	var output_data = ItemDatabase.get_item(machine["current_output"])
	if output_data and output_data.category == ItemData.ItemCategory.POTION:
		GameManager.stats["potions_brewed"] += 1

	item_processed.emit(machine["current_input"], machine["current_output"])

	# Reset machine
	machine["current_recipe"] = ""
	machine["current_input"] = ""
	machine["current_output"] = ""
	machine["timer_id"] = ""
	machine["state"] = "idle"

	_update_cell_display(grid_pos)
	_update_info_panel()


func _update_display() -> void:
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			_update_cell_display(Vector2i(x, y))
	_update_info_panel()


func _update_cell_display(grid_pos: Vector2i) -> void:
	var cell = grid_container.get_node_or_null("Cell_%d_%d" % [grid_pos.x, grid_pos.y])
	if not cell:
		return

	var icon = cell.get_node("VBoxContainer/Icon") if cell.has_node("VBoxContainer/Icon") else null
	var progress = cell.get_node("VBoxContainer/ProgressBar") if cell.has_node("VBoxContainer/ProgressBar") else null

	# Try alternate path
	if not icon:
		for child in cell.get_children():
			if child is VBoxContainer:
				icon = child.get_node_or_null("Icon")
				progress = child.get_node_or_null("ProgressBar")
				break

	if grid.has(grid_pos):
		var machine = grid[grid_pos]
		var data = machine["data"] as MachineData

		# Update icon color based on machine type
		if icon:
			icon.modulate = data.get_category_color()

		# Update progress bar
		if progress:
			if machine["state"] == "processing" and machine["timer_id"] != "":
				progress.visible = true
				progress.value = TimeManager.get_timer_progress(machine["timer_id"]) * 100
			else:
				progress.visible = false

		# Highlight if selected
		var style = cell.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if grid_pos == selected_grid_pos:
			style.border_color = Color("#6C5CE7")
			style.border_width_left = 3
			style.border_width_right = 3
			style.border_width_top = 3
			style.border_width_bottom = 3
		else:
			style.border_color = Color(0.7, 0.68, 0.65)
			style.border_width_left = 1
			style.border_width_right = 1
			style.border_width_top = 1
			style.border_width_bottom = 1
		style.bg_color = data.get_category_color().lightened(0.7)
		cell.add_theme_stylebox_override("panel", style)
	else:
		# Empty cell
		if icon:
			icon.modulate = Color(0.8, 0.78, 0.75)
		if progress:
			progress.visible = false

		var style = cell.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		style.bg_color = Color(0.9, 0.88, 0.85)
		style.border_color = Color(0.7, 0.68, 0.65)
		cell.add_theme_stylebox_override("panel", style)


func _process(_delta: float) -> void:
	# Update progress bars for processing machines
	for grid_pos in grid:
		var machine = grid[grid_pos]
		if machine["state"] == "processing":
			_update_cell_display(grid_pos)


# Save/Load
func get_save_data() -> Dictionary:
	var grid_data = {}
	for pos in grid:
		var machine = grid[pos]
		grid_data["%d,%d" % [pos.x, pos.y]] = {
			"machine_id": machine["machine_id"],
			"speed_level": machine["speed_level"],
			"efficiency_level": machine["efficiency_level"],
			"automation_level": machine["automation_level"]
		}
	return {"grid": grid_data}


func load_save_data(data: Dictionary) -> void:
	grid.clear()
	var grid_data = data.get("grid", {})
	for pos_str in grid_data:
		var parts = pos_str.split(",")
		var pos = Vector2i(int(parts[0]), int(parts[1]))
		var machine_data = grid_data[pos_str]
		_place_machine(pos, machine_data["machine_id"])
		grid[pos]["speed_level"] = machine_data.get("speed_level", 1)
		grid[pos]["efficiency_level"] = machine_data.get("efficiency_level", 1)
		grid[pos]["automation_level"] = machine_data.get("automation_level", 1)
	_update_display()

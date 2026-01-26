extends Control
class_name MachineBase
## Base class for all workshop machines

signal processing_started(machine: MachineBase)
signal processing_completed(machine: MachineBase, output_item: String, amount: int)
signal processing_cancelled(machine: MachineBase)

@export var machine_data: MachineData

# Current state
enum State { IDLE, PROCESSING, COMPLETE }
var current_state: State = State.IDLE

# Processing
var current_input_item: String = ""
var current_input_amount: int = 0
var processing_timer_id: String = ""

# Upgrade levels
var speed_level: int = 1
var efficiency_level: int = 1
var automation_level: int = 1

# Queue
var input_queue: Array[Dictionary] = []  # [{ "item_id": String, "amount": int }]
var output_buffer: Array[Dictionary] = []

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var status_label: Label = $StatusLabel
@onready var icon_texture: TextureRect = $Icon


func _ready() -> void:
	if machine_data:
		_setup_machine()
	TimeManager.tick.connect(_on_tick)


func _setup_machine() -> void:
	if machine_data.icon:
		icon_texture.texture = machine_data.icon
	_update_display()


func _on_tick() -> void:
	if current_state == State.PROCESSING:
		_update_progress_display()


# Input handling
func can_accept_input(item_id: String) -> bool:
	if current_state != State.IDLE:
		return false

	# Check if machine accepts this item type
	if machine_data.accepted_item_types.size() > 0:
		return item_id in machine_data.accepted_item_types

	return true


func add_input(item_id: String, amount: int = 1) -> bool:
	if not can_accept_input(item_id):
		return false

	if not GameManager.has_item(item_id, amount):
		return false

	# Remove from inventory and start processing
	GameManager.remove_item(item_id, amount)
	current_input_item = item_id
	current_input_amount = amount
	_start_processing()
	return true


# Processing
func _start_processing() -> void:
	current_state = State.PROCESSING

	# Calculate processing time with upgrades
	var base_time = _get_process_time_for_item(current_input_item)
	var speed_mult = machine_data.get_speed_at_level(speed_level)
	var actual_time = base_time / speed_mult

	# Start timer
	processing_timer_id = "machine_%s_%d" % [machine_data.id, Time.get_ticks_msec()]
	TimeManager.start_timer(
		processing_timer_id,
		actual_time,
		_on_processing_complete
	)

	processing_started.emit(self)
	_update_display()


func _get_process_time_for_item(_item_id: String) -> float:
	# Base processing time - can be overridden per item
	return 30.0 * machine_data.process_time_multiplier


func _on_processing_complete(_data: Variant = null) -> void:
	current_state = State.COMPLETE

	# Determine output
	var output_item = _get_output_for_item(current_input_item)
	var output_amount = current_input_amount

	# Check for efficiency bonus
	var efficiency = machine_data.get_efficiency_at_level(efficiency_level)
	if randf() < efficiency:
		output_amount += 1

	# Add to output buffer
	output_buffer.append({
		"item_id": output_item,
		"amount": output_amount
	})

	processing_completed.emit(self, output_item, output_amount)

	# Auto-collect if automation level is high enough
	if automation_level >= 4:
		collect_output()
	else:
		_update_display()


func _get_output_for_item(input_item: String) -> String:
	# This should lookup the item's "processes_into" field
	# For now, return a simple transformation
	return input_item + "_processed"


func collect_output() -> void:
	for output in output_buffer:
		GameManager.add_item(output["item_id"], output["amount"])

	output_buffer.clear()
	current_state = State.IDLE
	current_input_item = ""
	current_input_amount = 0

	# Check queue for next item
	if automation_level >= 3 and input_queue.size() > 0:
		var next_input = input_queue.pop_front()
		add_input(next_input["item_id"], next_input["amount"])
	else:
		_update_display()


func cancel_processing() -> void:
	if current_state == State.PROCESSING:
		TimeManager.cancel_timer(processing_timer_id)
		# Return input to inventory
		GameManager.add_item(current_input_item, current_input_amount)
		current_state = State.IDLE
		current_input_item = ""
		current_input_amount = 0
		processing_cancelled.emit(self)
		_update_display()


# Display
func _update_display() -> void:
	match current_state:
		State.IDLE:
			status_label.text = "Idle"
			progress_bar.value = 0
		State.PROCESSING:
			status_label.text = "Processing..."
			_update_progress_display()
		State.COMPLETE:
			status_label.text = "Complete!"
			progress_bar.value = 100


func _update_progress_display() -> void:
	var progress = TimeManager.get_timer_progress(processing_timer_id)
	progress_bar.value = progress * 100

	var remaining = TimeManager.get_timer_remaining(processing_timer_id)
	status_label.text = TimeManager.format_time(remaining)


# Upgrades
func upgrade_speed() -> bool:
	if speed_level >= machine_data.max_speed_level:
		return false

	var cost = machine_data.get_upgrade_cost("speed", speed_level)
	if GameManager.spend_gold(cost):
		speed_level += 1
		return true
	return false


func upgrade_efficiency() -> bool:
	if efficiency_level >= machine_data.max_efficiency_level:
		return false

	var cost = machine_data.get_upgrade_cost("efficiency", efficiency_level)
	if GameManager.spend_gold(cost):
		efficiency_level += 1
		return true
	return false


func upgrade_automation() -> bool:
	if automation_level >= machine_data.max_automation_level:
		return false

	var cost = machine_data.get_upgrade_cost("automation", automation_level)
	if GameManager.spend_gold(cost):
		automation_level += 1
		return true
	return false


# Save/Load
func get_save_data() -> Dictionary:
	return {
		"machine_id": machine_data.id if machine_data else "",
		"current_state": current_state,
		"current_input_item": current_input_item,
		"current_input_amount": current_input_amount,
		"speed_level": speed_level,
		"efficiency_level": efficiency_level,
		"automation_level": automation_level,
		"input_queue": input_queue,
		"output_buffer": output_buffer
	}


func load_save_data(data: Dictionary) -> void:
	current_state = data.get("current_state", State.IDLE)
	current_input_item = data.get("current_input_item", "")
	current_input_amount = data.get("current_input_amount", 0)
	speed_level = data.get("speed_level", 1)
	efficiency_level = data.get("efficiency_level", 1)
	automation_level = data.get("automation_level", 1)
	input_queue = data.get("input_queue", [])
	output_buffer = data.get("output_buffer", [])
	_update_display()

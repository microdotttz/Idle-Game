extends Button
class_name ProgressButton
## Button with an integrated progress bar, useful for timed actions

signal progress_completed

@export var duration: float = 1.0
@export var auto_reset: bool = true
@export var show_time_label: bool = true

var is_progressing: bool = false
var progress: float = 0.0
var _timer_id: String = ""

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var time_label: Label = $TimeLabel


func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	pressed.connect(_on_pressed)
	_update_display()


func start_progress(custom_duration: float = -1.0) -> void:
	if is_progressing:
		return

	var actual_duration = custom_duration if custom_duration > 0 else duration
	is_progressing = true
	progress = 0.0
	disabled = true

	_timer_id = "progress_btn_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(_timer_id, actual_duration, _on_timer_complete)
	_update_display()


func cancel_progress() -> void:
	if not is_progressing:
		return

	TimeManager.cancel_timer(_timer_id)
	is_progressing = false
	progress = 0.0
	disabled = false
	_update_display()


func _on_timer_complete(_data: Variant = null) -> void:
	is_progressing = false
	progress = 1.0
	progress_completed.emit()

	if auto_reset:
		progress = 0.0
		disabled = false

	_update_display()


func _on_tick() -> void:
	if is_progressing:
		progress = TimeManager.get_timer_progress(_timer_id)
		_update_display()


func _update_display() -> void:
	progress_bar.value = progress * 100

	if show_time_label and is_progressing:
		var remaining = TimeManager.get_timer_remaining(_timer_id)
		time_label.text = TimeManager.format_time(remaining)
		time_label.visible = true
	else:
		time_label.visible = false


func _on_pressed() -> void:
	if not is_progressing:
		start_progress()

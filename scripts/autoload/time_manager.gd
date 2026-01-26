extends Node
## TimeManager - Handles time-based progression and offline gains
## Calculates what happened while the player was away

signal offline_progress_calculated(results: Dictionary)
signal tick  # Emitted every game tick for active timers

const MAX_OFFLINE_HOURS = 8  # Cap offline progress
const TICK_RATE = 1.0  # Seconds between ticks

# Active timers for machines, growing plants, etc.
# Format: { "id": { "remaining": float, "callback": Callable, "data": Variant } }
var active_timers: Dictionary = {}

# Queued production (machines, gardens, etc.)
var production_queues: Dictionary = {}

var _tick_timer: Timer


func _ready() -> void:
	_tick_timer = Timer.new()
	_tick_timer.wait_time = TICK_RATE
	_tick_timer.autostart = true
	_tick_timer.timeout.connect(_on_tick)
	add_child(_tick_timer)


func _on_tick() -> void:
	tick.emit()
	_process_active_timers(TICK_RATE)


func _process_active_timers(delta: float) -> void:
	var completed = []

	for timer_id in active_timers:
		var timer = active_timers[timer_id]
		timer["remaining"] -= delta

		if timer["remaining"] <= 0:
			completed.append(timer_id)
			if timer.has("callback") and timer["callback"].is_valid():
				timer["callback"].call(timer.get("data"))

	for timer_id in completed:
		active_timers.erase(timer_id)


# Timer Management
func start_timer(timer_id: String, duration: float, callback: Callable = Callable(), data: Variant = null) -> void:
	active_timers[timer_id] = {
		"remaining": duration,
		"total": duration,
		"callback": callback,
		"data": data
	}


func cancel_timer(timer_id: String) -> void:
	active_timers.erase(timer_id)


func get_timer_remaining(timer_id: String) -> float:
	if active_timers.has(timer_id):
		return active_timers[timer_id]["remaining"]
	return 0.0


func get_timer_progress(timer_id: String) -> float:
	if active_timers.has(timer_id):
		var timer = active_timers[timer_id]
		return 1.0 - (timer["remaining"] / timer["total"])
	return 1.0


func is_timer_active(timer_id: String) -> bool:
	return active_timers.has(timer_id)


# Offline Progress Calculation
func process_offline_time(seconds: float) -> void:
	# Cap offline time
	var max_seconds = MAX_OFFLINE_HOURS * 3600
	seconds = min(seconds, max_seconds)

	if seconds < 60:  # Less than a minute, skip
		return

	var results = {
		"time_away": seconds,
		"gold_earned": 0,
		"items_produced": {},
		"plants_grown": 0,
		"potions_sold": 0
	}

	# Process all active timers with offline time
	_process_active_timers(seconds)

	# Calculate passive earnings from shop (if automated)
	results["gold_earned"] = _calculate_offline_shop_earnings(seconds)

	# Add gold
	if results["gold_earned"] > 0:
		GameManager.add_gold(results["gold_earned"])

	offline_progress_calculated.emit(results)
	_show_offline_summary(results)


func _calculate_offline_shop_earnings(seconds: float) -> int:
	# Simple offline earning based on reputation tier
	# Higher tier = more passive income
	var base_rate = 0.5  # gold per minute at tier 1
	var tier_multiplier = GameManager.reputation_tier
	var minutes = seconds / 60.0

	return int(base_rate * tier_multiplier * minutes)


func _show_offline_summary(results: Dictionary) -> void:
	var hours = int(results["time_away"] / 3600)
	var minutes = int((int(results["time_away"]) % 3600) / 60)

	print("Welcome back!")
	print("You were away for ", hours, "h ", minutes, "m")
	print("Gold earned: ", results["gold_earned"])
	# TODO: Show UI popup with summary


# Save/Load
func get_save_data() -> Dictionary:
	var timer_data = {}
	for timer_id in active_timers:
		timer_data[timer_id] = {
			"remaining": active_timers[timer_id]["remaining"],
			"total": active_timers[timer_id]["total"]
		}

	return {
		"active_timers": timer_data,
		"production_queues": production_queues.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	# Note: Callbacks can't be saved, so timers need to be re-registered
	# by the respective systems after loading
	production_queues = data.get("production_queues", {})


# Utility
func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	if total_seconds >= 3600:
		var h = total_seconds / 3600
		var m = (total_seconds % 3600) / 60
		return "%d:%02d:%02d" % [h, m, total_seconds % 60]
	else:
		var m = total_seconds / 60
		var s = total_seconds % 60
		return "%d:%02d" % [m, s]

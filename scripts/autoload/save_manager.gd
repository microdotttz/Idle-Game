extends Node
## SaveManager - Handles saving and loading game state
## Saves to user:// directory (app data folder on mobile)

const SAVE_PATH = "user://potion_shop_save.json"

signal game_saved
signal game_loaded


func _ready() -> void:
	# Auto-save periodically
	var timer = Timer.new()
	timer.wait_time = 60.0  # Save every minute
	timer.autostart = true
	timer.timeout.connect(_on_autosave_timer)
	add_child(timer)


func _notification(what: int) -> void:
	# Save when app is paused or closed
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func save_game() -> void:
	var save_data = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"game": GameManager.get_save_data(),
		"time": TimeManager.get_save_data()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		game_saved.emit()
		print("Game saved at ", Time.get_datetime_string_from_system())
	else:
		push_error("Failed to save game: ", FileAccess.get_open_error())


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found, starting fresh")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to load save file")
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse save file: ", json.get_error_message())
		return false

	var save_data = json.data
	if typeof(save_data) != TYPE_DICTIONARY:
		push_error("Invalid save file format")
		return false

	# Load data into managers
	if save_data.has("game"):
		GameManager.load_save_data(save_data["game"])

	if save_data.has("time"):
		TimeManager.load_save_data(save_data["time"])

	# Calculate offline progress
	if save_data.has("timestamp"):
		var offline_seconds = Time.get_unix_time_from_system() - save_data["timestamp"]
		TimeManager.process_offline_time(offline_seconds)

	game_loaded.emit()
	print("Game loaded successfully")
	return true


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted")


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _on_autosave_timer() -> void:
	save_game()

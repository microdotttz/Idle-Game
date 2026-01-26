extends PanelContainer
class_name ItemSlot
## Reusable item slot component for displaying items in inventory/storage

signal slot_pressed(slot: ItemSlot)
signal slot_long_pressed(slot: ItemSlot)

@export var show_quantity: bool = true
@export var show_name: bool = false
@export var clickable: bool = true
@export var slot_size: Vector2 = Vector2(80, 80)

var item_id: String = ""
var quantity: int = 0
var item_data: ItemData = null

var _press_timer: Timer
var _is_pressing: bool = false
const LONG_PRESS_TIME = 0.5

@onready var icon: TextureRect = $VBox/IconContainer/Icon
@onready var quantity_label: Label = $VBox/IconContainer/QuantityLabel
@onready var name_label: Label = $VBox/NameLabel
@onready var rarity_border: Panel = $VBox/IconContainer/RarityBorder


func _ready() -> void:
	custom_minimum_size = slot_size

	_press_timer = Timer.new()
	_press_timer.one_shot = true
	_press_timer.wait_time = LONG_PRESS_TIME
	_press_timer.timeout.connect(_on_long_press)
	add_child(_press_timer)

	gui_input.connect(_on_gui_input)
	_update_display()


func set_item(new_item_id: String, new_quantity: int = 1) -> void:
	item_id = new_item_id
	quantity = new_quantity

	if item_id != "":
		item_data = ItemDatabase.get_item(item_id)
	else:
		item_data = null

	_update_display()


func clear() -> void:
	set_item("", 0)


func _update_display() -> void:
	if item_data == null or item_id == "":
		icon.texture = null
		icon.modulate = Color.WHITE
		quantity_label.visible = false
		name_label.visible = false
		rarity_border.visible = false
		modulate.a = 0.5
		return

	modulate.a = 1.0

	# Set icon (use placeholder color for now)
	if item_data.icon:
		icon.texture = item_data.icon
	else:
		# Use colored placeholder based on category
		icon.modulate = item_data.get_category_color()

	# Quantity
	quantity_label.visible = show_quantity and quantity > 1
	quantity_label.text = str(quantity)

	# Name
	name_label.visible = show_name
	name_label.text = item_data.display_name

	# Rarity border
	rarity_border.visible = item_data.rarity != ItemData.Rarity.COMMON
	if rarity_border.visible:
		var style = StyleBoxFlat.new()
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = item_data.get_rarity_color()
		style.bg_color = Color.TRANSPARENT
		rarity_border.add_theme_stylebox_override("panel", style)


func _on_gui_input(event: InputEvent) -> void:
	if not clickable:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pressing = true
				_press_timer.start()
			else:
				_press_timer.stop()
				if _is_pressing:
					slot_pressed.emit(self)
				_is_pressing = false

	elif event is InputEventScreenTouch:
		if event.pressed:
			_is_pressing = true
			_press_timer.start()
		else:
			_press_timer.stop()
			if _is_pressing:
				slot_pressed.emit(self)
			_is_pressing = false


func _on_long_press() -> void:
	_is_pressing = false
	slot_long_pressed.emit(self)

extends PanelContainer
class_name Customer
## A customer that wants to buy potions

signal customer_served(customer: Customer, gold_earned: int)
signal customer_left(customer: Customer, satisfied: bool)

enum CustomerType { VILLAGER, ADVENTURER, MERCHANT, KNIGHT, WIZARD, NOBLE }

@export var customer_type: CustomerType = CustomerType.VILLAGER

var wanted_item: String = ""
var wanted_quantity: int = 1
var patience: float = 30.0  # Seconds before leaving
var pay_multiplier: float = 1.0
var is_waiting: bool = true

var _patience_timer_id: String = ""

@onready var portrait: TextureRect = $HBox/Portrait
@onready var type_label: Label = $HBox/Info/TypeLabel
@onready var want_label: Label = $HBox/Info/WantLabel
@onready var patience_bar: ProgressBar = $HBox/Info/PatienceBar
@onready var serve_button: Button = $HBox/ServeButton


func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	serve_button.pressed.connect(_on_serve_pressed)


func setup(type: CustomerType, item_id: String, quantity: int = 1) -> void:
	customer_type = type
	wanted_item = item_id
	wanted_quantity = quantity

	# Set properties based on type
	match customer_type:
		CustomerType.VILLAGER:
			patience = 60.0
			pay_multiplier = 1.0
		CustomerType.ADVENTURER:
			patience = 45.0
			pay_multiplier = 1.2
		CustomerType.MERCHANT:
			patience = 60.0
			pay_multiplier = 0.9
		CustomerType.KNIGHT:
			patience = 30.0
			pay_multiplier = 1.5
		CustomerType.WIZARD:
			patience = 20.0
			pay_multiplier = 2.0
		CustomerType.NOBLE:
			patience = 10.0
			pay_multiplier = 3.0

	_start_patience_timer()
	_update_display()


func _start_patience_timer() -> void:
	_patience_timer_id = "customer_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(_patience_timer_id, patience, _on_patience_expired)


func _on_patience_expired(_data: Variant = null) -> void:
	if is_waiting:
		is_waiting = false
		customer_left.emit(self, false)


func _on_serve_pressed() -> void:
	if not is_waiting:
		return

	# Check if we have the item
	if not GameManager.has_item(wanted_item, wanted_quantity):
		# Show "out of stock" feedback
		return

	# Serve the customer
	GameManager.remove_item(wanted_item, wanted_quantity)

	var item_data = ItemDatabase.get_item(wanted_item)
	var gold_earned = int(item_data.base_value * wanted_quantity * pay_multiplier)

	GameManager.add_gold(gold_earned)
	GameManager.add_reputation(wanted_quantity)
	GameManager.stats["potions_sold"] += wanted_quantity

	TimeManager.cancel_timer(_patience_timer_id)
	is_waiting = false

	customer_served.emit(self, gold_earned)


func can_serve() -> bool:
	return is_waiting and GameManager.has_item(wanted_item, wanted_quantity)


func _on_tick() -> void:
	if is_waiting:
		_update_display()


func _update_display() -> void:
	# Type label
	type_label.text = CustomerType.keys()[customer_type].capitalize()

	# Portrait color based on type
	var type_colors = {
		CustomerType.VILLAGER: Color("#74B9FF"),
		CustomerType.ADVENTURER: Color("#00B894"),
		CustomerType.MERCHANT: Color("#FDCB6E"),
		CustomerType.KNIGHT: Color("#636E72"),
		CustomerType.WIZARD: Color("#6C5CE7"),
		CustomerType.NOBLE: Color("#E17055")
	}
	portrait.modulate = type_colors.get(customer_type, Color.WHITE)

	# Want label
	var item_data = ItemDatabase.get_item(wanted_item)
	if item_data:
		want_label.text = "Wants: %dx %s" % [wanted_quantity, item_data.display_name]
	else:
		want_label.text = "Wants: %dx %s" % [wanted_quantity, wanted_item]

	# Patience bar
	if is_waiting and _patience_timer_id != "":
		var remaining_ratio = TimeManager.get_timer_remaining(_patience_timer_id) / patience
		patience_bar.value = remaining_ratio * 100

		# Color based on patience
		if remaining_ratio > 0.5:
			patience_bar.modulate = Color("#00B894")
		elif remaining_ratio > 0.25:
			patience_bar.modulate = Color("#FDCB6E")
		else:
			patience_bar.modulate = Color("#E17055")

	# Serve button
	serve_button.disabled = not can_serve()
	if can_serve():
		var item = ItemDatabase.get_item(wanted_item)
		var gold = int(item.base_value * wanted_quantity * pay_multiplier)
		serve_button.text = "Sell (%dg)" % gold
	else:
		serve_button.text = "No Stock"


func get_type_name() -> String:
	return CustomerType.keys()[customer_type].capitalize()

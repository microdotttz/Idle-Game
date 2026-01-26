extends Control
class_name ShopManager
## Manages the shop view - customers, shelves, and sales

signal sale_made(item_id: String, quantity: int, gold: int)

const MAX_CUSTOMERS = 4
const CUSTOMER_SPAWN_TIME_MIN = 10.0
const CUSTOMER_SPAWN_TIME_MAX = 30.0

# Shelf stock: item_id -> quantity on display
var shelf_stock: Dictionary = {}
const MAX_SHELF_SLOTS = 8

var customers: Array[Customer] = []
var _spawn_timer_id: String = ""

@onready var customer_container: VBoxContainer = $MainContent/CustomerSection/CustomerScroll/CustomerList
@onready var shelf_grid: GridContainer = $MainContent/ShelfSection/ShelfGrid
@onready var restock_button: Button = $MainContent/ShelfSection/RestockButton
@onready var no_customers_label: Label = $MainContent/CustomerSection/NoCustomersLabel

var customer_scene: PackedScene
var item_slot_scene: PackedScene


func _ready() -> void:
	customer_scene = preload("res://scenes/ui/components/customer.tscn")
	item_slot_scene = preload("res://scenes/ui/components/item_slot.tscn")

	restock_button.pressed.connect(_on_restock_pressed)

	_setup_shelf_slots()
	_schedule_next_customer()
	_update_display()


func _setup_shelf_slots() -> void:
	# Clear existing
	for child in shelf_grid.get_children():
		child.queue_free()

	# Create shelf slots
	for i in range(MAX_SHELF_SLOTS):
		var slot = item_slot_scene.instantiate() as ItemSlot
		slot.clickable = true
		slot.slot_pressed.connect(_on_shelf_slot_pressed)
		shelf_grid.add_child(slot)


func _schedule_next_customer() -> void:
	var wait_time = randf_range(CUSTOMER_SPAWN_TIME_MIN, CUSTOMER_SPAWN_TIME_MAX)
	# Reduce wait time based on reputation
	wait_time *= 1.0 / (1.0 + GameManager.reputation_tier * 0.1)

	_spawn_timer_id = "customer_spawn_%d" % Time.get_ticks_msec()
	TimeManager.start_timer(_spawn_timer_id, wait_time, _spawn_customer)


func _spawn_customer(_data: Variant = null) -> void:
	if customers.size() >= MAX_CUSTOMERS:
		_schedule_next_customer()
		return

	# Determine customer type based on reputation
	var type = _get_random_customer_type()

	# Determine what they want (from available potions)
	var wanted = _get_random_wanted_item(type)
	if wanted.is_empty():
		_schedule_next_customer()
		return

	# Create customer
	var customer = customer_scene.instantiate() as Customer
	customer.setup(type, wanted["item_id"], wanted["quantity"])
	customer.customer_served.connect(_on_customer_served)
	customer.customer_left.connect(_on_customer_left)

	customer_container.add_child(customer)
	customers.append(customer)

	_update_display()
	_schedule_next_customer()


func _get_random_customer_type() -> Customer.CustomerType:
	var tier = GameManager.reputation_tier
	var roll = randf()

	# Higher tier = better customers
	if tier >= 6 and roll < 0.1:
		return Customer.CustomerType.NOBLE
	elif tier >= 5 and roll < 0.15:
		return Customer.CustomerType.WIZARD
	elif tier >= 4 and roll < 0.2:
		return Customer.CustomerType.KNIGHT
	elif tier >= 2 and roll < 0.3:
		return Customer.CustomerType.MERCHANT
	elif roll < 0.5:
		return Customer.CustomerType.ADVENTURER
	else:
		return Customer.CustomerType.VILLAGER


func _get_random_wanted_item(type: Customer.CustomerType) -> Dictionary:
	# Get potions from inventory or shelf
	var available_potions: Array[String] = []

	for item_id in GameManager.inventory:
		var item = ItemDatabase.get_item(item_id)
		if item and item.category == ItemData.ItemCategory.POTION:
			available_potions.append(item_id)

	for item_id in shelf_stock:
		if item_id not in available_potions:
			var item = ItemDatabase.get_item(item_id)
			if item and item.category == ItemData.ItemCategory.POTION:
				available_potions.append(item_id)

	if available_potions.is_empty():
		# Request a basic potion they hope we have
		var basic_potions = ["health_potion", "mana_potion", "stamina_tonic"]
		return {
			"item_id": basic_potions[randi() % basic_potions.size()],
			"quantity": 1
		}

	var item_id = available_potions[randi() % available_potions.size()]
	var quantity = 1

	# Merchants want bulk
	if type == Customer.CustomerType.MERCHANT:
		quantity = randi_range(3, 5)

	return {"item_id": item_id, "quantity": quantity}


func _on_customer_served(customer: Customer, gold_earned: int) -> void:
	sale_made.emit(customer.wanted_item, customer.wanted_quantity, gold_earned)
	_remove_customer(customer)


func _on_customer_left(customer: Customer, _satisfied: bool) -> void:
	_remove_customer(customer)


func _remove_customer(customer: Customer) -> void:
	customers.erase(customer)
	customer.queue_free()
	_update_display()


# Shelf management
func add_to_shelf(item_id: String, quantity: int = 1) -> bool:
	if not GameManager.has_item(item_id, quantity):
		return false

	# Find empty slot or existing stack
	var total_on_shelf = 0
	for id in shelf_stock:
		total_on_shelf += 1

	if not shelf_stock.has(item_id) and total_on_shelf >= MAX_SHELF_SLOTS:
		return false

	GameManager.remove_item(item_id, quantity)

	if shelf_stock.has(item_id):
		shelf_stock[item_id] += quantity
	else:
		shelf_stock[item_id] = quantity

	_update_shelf_display()
	return true


func remove_from_shelf(item_id: String, quantity: int = 1) -> bool:
	if not shelf_stock.has(item_id) or shelf_stock[item_id] < quantity:
		return false

	shelf_stock[item_id] -= quantity
	if shelf_stock[item_id] <= 0:
		shelf_stock.erase(item_id)

	GameManager.add_item(item_id, quantity)
	_update_shelf_display()
	return true


func _on_shelf_slot_pressed(slot: ItemSlot) -> void:
	if slot.item_id != "":
		# Remove from shelf back to inventory
		remove_from_shelf(slot.item_id, 1)


func _on_restock_pressed() -> void:
	# Quick restock - add all potions from inventory to shelf
	var potions_to_add: Dictionary = {}

	for item_id in GameManager.inventory:
		var item = ItemDatabase.get_item(item_id)
		if item and item.category == ItemData.ItemCategory.POTION:
			potions_to_add[item_id] = GameManager.inventory[item_id]

	for item_id in potions_to_add:
		add_to_shelf(item_id, potions_to_add[item_id])


func _update_display() -> void:
	no_customers_label.visible = customers.is_empty()
	_update_shelf_display()


func _update_shelf_display() -> void:
	var slots = shelf_grid.get_children()
	var slot_index = 0

	# Fill slots with shelf stock
	for item_id in shelf_stock:
		if slot_index < slots.size():
			slots[slot_index].set_item(item_id, shelf_stock[item_id])
			slot_index += 1

	# Clear remaining slots
	while slot_index < slots.size():
		slots[slot_index].clear()
		slot_index += 1


# Save/Load
func get_save_data() -> Dictionary:
	return {
		"shelf_stock": shelf_stock.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	shelf_stock = data.get("shelf_stock", {})
	_update_display()

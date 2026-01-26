extends Control
class_name InventoryPopup
## Popup showing player inventory with filtering and sorting

signal item_selected(item_id: String)
signal closed

enum FilterCategory { ALL, BOTANICAL, MINERAL, CREATURE, ELEMENTAL, FISH, POTION }
enum SortMode { NAME, QUANTITY, VALUE, RECENT }

var current_filter: FilterCategory = FilterCategory.ALL
var current_sort: SortMode = SortMode.NAME
var is_visible: bool = false

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var filter_buttons: HBoxContainer = $Panel/VBox/FilterBar
@onready var item_grid: GridContainer = $Panel/VBox/ItemScroll/ItemGrid
@onready var item_count_label: Label = $Panel/VBox/Header/ItemCountLabel
@onready var gold_label: Label = $Panel/VBox/Header/GoldLabel

var item_slot_scene: PackedScene


func _ready() -> void:
	item_slot_scene = preload("res://scenes/ui/components/item_slot.tscn")

	close_button.pressed.connect(hide_popup)
	background.gui_input.connect(_on_background_input)

	GameManager.item_added.connect(_on_inventory_changed)
	GameManager.item_removed.connect(_on_inventory_changed)
	GameManager.gold_changed.connect(_on_gold_changed)

	_setup_filters()
	hide_popup()


func _setup_filters() -> void:
	for child in filter_buttons.get_children():
		child.queue_free()

	var filters = ["All", "Plants", "Minerals", "Creature", "Elemental", "Fish", "Potions"]
	for i in range(filters.size()):
		var btn = Button.new()
		btn.text = filters[i]
		btn.toggle_mode = true
		btn.button_pressed = (i == current_filter)
		btn.pressed.connect(_on_filter_pressed.bind(i, btn))
		filter_buttons.add_child(btn)


func _on_filter_pressed(filter_index: int, button: Button) -> void:
	current_filter = filter_index as FilterCategory

	# Update button states
	for child in filter_buttons.get_children():
		if child is Button:
			child.button_pressed = (child == button)

	_refresh_display()


func show_popup() -> void:
	is_visible = true
	visible = true
	_refresh_display()


func hide_popup() -> void:
	is_visible = false
	visible = false
	closed.emit()


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_popup()


func _on_inventory_changed(_item_id: String, _amount: int) -> void:
	if is_visible:
		_refresh_display()


func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "%dg" % new_amount


func _refresh_display() -> void:
	# Clear grid
	for child in item_grid.get_children():
		child.queue_free()

	# Get filtered and sorted items
	var items = _get_filtered_items()
	items = _sort_items(items)

	# Update count
	var total_items = 0
	for item_id in GameManager.inventory:
		total_items += GameManager.inventory[item_id]
	item_count_label.text = "%d items" % total_items
	gold_label.text = "%dg" % GameManager.gold

	# Create item slots
	for item in items:
		var slot = item_slot_scene.instantiate() as ItemSlot
		slot.set_item(item["id"], item["quantity"])
		slot.show_name = true
		slot.slot_pressed.connect(_on_item_slot_pressed)
		item_grid.add_child(slot)


func _get_filtered_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []

	for item_id in GameManager.inventory:
		var quantity = GameManager.inventory[item_id]
		var item_data = ItemDatabase.get_item(item_id)

		if not item_data:
			continue

		# Apply filter
		var pass_filter = false
		match current_filter:
			FilterCategory.ALL:
				pass_filter = true
			FilterCategory.BOTANICAL:
				pass_filter = item_data.category == ItemData.ItemCategory.BOTANICAL
			FilterCategory.MINERAL:
				pass_filter = item_data.category == ItemData.ItemCategory.MINERAL
			FilterCategory.CREATURE:
				pass_filter = item_data.category == ItemData.ItemCategory.CREATURE
			FilterCategory.ELEMENTAL:
				pass_filter = item_data.category == ItemData.ItemCategory.ELEMENTAL
			FilterCategory.FISH:
				pass_filter = item_data.category == ItemData.ItemCategory.FISH
			FilterCategory.POTION:
				pass_filter = item_data.category == ItemData.ItemCategory.POTION

		if pass_filter:
			items.append({
				"id": item_id,
				"quantity": quantity,
				"data": item_data
			})

	return items


func _sort_items(items: Array[Dictionary]) -> Array[Dictionary]:
	match current_sort:
		SortMode.NAME:
			items.sort_custom(func(a, b): return a["data"].display_name < b["data"].display_name)
		SortMode.QUANTITY:
			items.sort_custom(func(a, b): return a["quantity"] > b["quantity"])
		SortMode.VALUE:
			items.sort_custom(func(a, b): return a["data"].base_value > b["data"].base_value)

	return items


func _on_item_slot_pressed(slot: ItemSlot) -> void:
	item_selected.emit(slot.item_id)

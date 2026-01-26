extends Control
## Main scene - Container for all game screens with tab navigation

signal tab_changed(tab_index: int)

enum Tab { SHOP, WORKSHOP, GARDEN, ACTIVITIES }

var current_tab: Tab = Tab.SHOP

@onready var top_bar: HBoxContainer = $TopBar
@onready var gold_label: Label = $TopBar/GoldLabel
@onready var mana_label: Label = $TopBar/ManaLabel
@onready var inventory_button: Button = $TopBar/InventoryButton

@onready var content_container: Control = $ContentContainer
@onready var shop_scene: Control = $ContentContainer/Shop
@onready var workshop_scene: Control = $ContentContainer/Workshop
@onready var garden_scene: Control = $ContentContainer/Garden
@onready var activities_scene: Control = $ContentContainer/Activities

@onready var bottom_nav: HBoxContainer = $BottomNav
@onready var inventory_popup: Control = $InventoryPopup

var tab_scenes: Array[Control] = []


func _ready() -> void:
	# Initialize ItemDatabase
	ItemDatabase.initialize()

	# Setup tab scenes array
	tab_scenes = [shop_scene, workshop_scene, garden_scene, activities_scene]

	# Connect signals
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.mana_changed.connect(_on_mana_changed)

	# Setup bottom nav buttons
	_setup_bottom_nav()

	# Setup inventory button
	inventory_button.pressed.connect(_on_inventory_button_pressed)

	# Load saved game
	SaveManager.load_game()

	# Update UI
	_update_currency_display()
	_switch_to_tab(Tab.SHOP)


func _setup_bottom_nav() -> void:
	var buttons = bottom_nav.get_children()
	var tab_names = ["Shop", "Workshop", "Garden", "Activities"]

	for i in range(min(buttons.size(), tab_names.size())):
		if buttons[i] is Button:
			buttons[i].text = tab_names[i]
			buttons[i].pressed.connect(_on_nav_button_pressed.bind(i))


func _on_nav_button_pressed(tab_index: int) -> void:
	_switch_to_tab(tab_index as Tab)


func _switch_to_tab(tab: Tab) -> void:
	current_tab = tab

	# Show/hide scenes
	for i in range(tab_scenes.size()):
		tab_scenes[i].visible = (i == tab)

	# Update button states
	var buttons = bottom_nav.get_children()
	for i in range(buttons.size()):
		if buttons[i] is Button:
			buttons[i].button_pressed = (i == tab)

	tab_changed.emit(tab)


func _update_currency_display() -> void:
	gold_label.text = "%dg" % GameManager.gold
	mana_label.text = "%d" % GameManager.mana


func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "%dg" % new_amount
	_animate_label(gold_label)


func _on_mana_changed(new_amount: int) -> void:
	mana_label.text = "%d" % new_amount
	_animate_label(mana_label)


func _animate_label(label: Label) -> void:
	# Simple bounce animation
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)


func _on_inventory_button_pressed() -> void:
	inventory_popup.show_popup()


# Quick access methods for other scenes
func get_shop() -> ShopManager:
	return shop_scene as ShopManager


func get_workshop() -> WorkshopManager:
	return workshop_scene as WorkshopManager


func get_garden() -> GardenManager:
	return garden_scene as GardenManager

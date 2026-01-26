extends Control
## Main scene - Container for all game screens with tab navigation

@onready var tab_container: TabContainer = $TabContainer
@onready var gold_label: Label = $TopBar/GoldLabel
@onready var mana_label: Label = $TopBar/ManaLabel

var current_tab: int = 0


func _ready() -> void:
	# Connect to game manager signals
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.mana_changed.connect(_on_mana_changed)

	# Load saved game
	SaveManager.load_game()

	# Update UI
	_update_currency_display()


func _update_currency_display() -> void:
	gold_label.text = str(GameManager.gold) + "g"
	mana_label.text = str(GameManager.mana)


func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = str(new_amount) + "g"
	# TODO: Add animation/tween for visual feedback


func _on_mana_changed(new_amount: int) -> void:
	mana_label.text = str(new_amount)


func switch_to_tab(tab_index: int) -> void:
	current_tab = tab_index
	tab_container.current_tab = tab_index


func _on_shop_button_pressed() -> void:
	switch_to_tab(0)


func _on_workshop_button_pressed() -> void:
	switch_to_tab(1)


func _on_garden_button_pressed() -> void:
	switch_to_tab(2)


func _on_activities_button_pressed() -> void:
	switch_to_tab(3)

extends Control
class_name ActivitiesManager
## Manages side activities - fishing, hunting, foraging

signal activity_completed(activity_type: String, rewards: Dictionary)

enum ActivityTab { FISHING, HUNTING, FORAGING }

var current_tab: ActivityTab = ActivityTab.FISHING

@onready var tab_buttons: HBoxContainer = $MainContent/TabButtons
@onready var tab_content: Control = $MainContent/TabContent
@onready var fishing_panel: Control = $MainContent/TabContent/FishingPanel
@onready var hunting_panel: Control = $MainContent/TabContent/HuntingPanel
@onready var foraging_panel: Control = $MainContent/TabContent/ForagingPanel


func _ready() -> void:
	_setup_tabs()
	_switch_tab(ActivityTab.FISHING)


func _setup_tabs() -> void:
	for child in tab_buttons.get_children():
		child.queue_free()

	var tabs = ["Fishing", "Hunting", "Foraging"]
	for i in range(tabs.size()):
		var btn = Button.new()
		btn.text = tabs[i]
		btn.toggle_mode = true
		btn.button_pressed = (i == current_tab)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		tab_buttons.add_child(btn)


func _on_tab_pressed(tab_index: int) -> void:
	_switch_tab(tab_index as ActivityTab)


func _switch_tab(tab: ActivityTab) -> void:
	current_tab = tab

	# Update button states
	var buttons = tab_buttons.get_children()
	for i in range(buttons.size()):
		if buttons[i] is Button:
			buttons[i].button_pressed = (i == tab)

	# Show/hide panels
	fishing_panel.visible = (tab == ActivityTab.FISHING)
	hunting_panel.visible = (tab == ActivityTab.HUNTING)
	foraging_panel.visible = (tab == ActivityTab.FORAGING)

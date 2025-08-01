extends CanvasLayer

signal back_pressed

@export var upgrades: Array[MetaUpgrade] = []

@onready var grid_container = %GridContainer
@onready var back_button = %BackButton

var meta_upgrade_card_scene = preload("res://scenes/ui/meta_upgrade_card.tscn")

func _ready():
	back_button.pressed.connect(on_back_pressed)
	
	for child in grid_container.get_children():
		child.queue_free()
	
	for upgrade in upgrades:
		var upgrade_instance = meta_upgrade_card_scene.instantiate() as MetaUpgradeCard
		grid_container.add_child(upgrade_instance)
		upgrade_instance.set_meta_upgrade(upgrade)


func on_back_pressed():
	back_pressed.emit()
	#ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")


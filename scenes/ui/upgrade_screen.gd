extends CanvasLayer
class_name UpgradeScreenUI

signal refresh
signal upgrade_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene

@onready var card_container: HBoxContainer = %CardContainer
@onready var refresh_button = %RefreshButton

var can_refresh: bool = false


func _ready():
	get_tree().paused = true
	if can_refresh:
		refresh_button.visible = true
		refresh_button.pressed.connect(on_refresh_pressed)


func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate() as AbilityUpgradeCard
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += .2


func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()


func on_refresh_pressed():
	refresh_upgrades()


func refresh_upgrades():
	refresh.emit()
	queue_free()

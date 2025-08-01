extends CanvasLayer
class_name UpgradeScreenUI

signal upgrade_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene

@onready var card_container: HBoxContainer = %CardContainer


func _ready():
	get_tree().paused = true


func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate() as AbilityUpgradeCard
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += .1


func on_upgrade_selected(upgrade: AbilityUpgrade):
	if upgrade.id != "refresh_cards":
		get_tree().paused = false
	
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	queue_free()

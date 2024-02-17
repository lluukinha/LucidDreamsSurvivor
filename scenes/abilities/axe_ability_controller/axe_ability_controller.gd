extends Node

var base_damage = 10
var current_damage = base_damage
var axe_ability_scene: PackedScene = preload("res://scenes/abilities/axe_ability/axe_ability.tscn")

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Player
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")

	if player == null || foreground_layer == null || !player.can_attack:
		return
	
	var axe_instance = axe_ability_scene.instantiate() as AxeAbility
	foreground_layer.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = current_damage


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		current_damage = current_damage + 2
	

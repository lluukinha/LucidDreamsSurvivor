extends Node

var super_axe_ability_scene: PackedScene = preload("res://scenes/abilities/super_axe_ability/super_axe_ability.tscn")

const BASE_RANGE = 100
var base_damage = 20
var additional_damage_percent = 1
var anvil_count = 0


func _ready():
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	set_ability()


func set_ability():
	var player = get_tree().get_first_node_in_group("player") as Player
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")

	if player == null || foreground_layer == null || !player.can_attack:
		return
	
	var super_axe_instance = super_axe_ability_scene.instantiate() as SuperAxeAbility
	foreground_layer.add_child(super_axe_instance)
	super_axe_instance.global_position = player.global_position
	super_axe_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
	var super_axes = get_tree().get_nodes_in_group("super_axe_ability") as Array[SuperAxeAbility]
	var additional_rotation_degrees = 360.0 / super_axes.size()
	var initial_rotation = additional_rotation_degrees
	for super_axe in super_axes:
		super_axe.base_rotation = Vector2.UP.rotated(deg_to_rad(initial_rotation))
		initial_rotation += additional_rotation_degrees
		super_axe.tween.stop()
		super_axe.global_position = player.global_position + (super_axe.base_rotation * super_axe.MAX_RADIUS)
		super_axe.create_rotation()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "super_axe_damage":
		additional_damage_percent = 1 + (current_upgrades["super_axe_damage"]["quantity"] * .1)
	if upgrade.id == "super_axe_amount":
		set_ability()

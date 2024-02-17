extends CanvasLayer
class_name UpgradesUI

@onready var upgrades_container: GridContainer = %UpgradesContainer

var upgrade_ui_scene = preload("res://scenes/ui/upgrade_ui.tscn")

var super_axe = preload("res://resources/upgrades/super_axe.tres")
var axe = preload("res://resources/upgrades/axe.tres")
var sword = preload("res://resources/upgrades/sword.tres")
var anvil = preload("res://resources/upgrades/anvil.tres")

var super_axe_amount = preload("res://resources/upgrades/super_axe_amount.tres")
var sword_amount = preload("res://resources/upgrades/sword_damage.tres")
var axe_amount = preload("res://resources/upgrades/axe_damage.tres")
var anvil_amount = preload("res://resources/upgrades/anvil_amount.tres")


func _ready():
	pass


func get_upgrades():
	var upgrades = get_tree().get_nodes_in_group("upgrade_ui")
	if upgrades == null || upgrades.size() == 0:
		return []
	return upgrades


func get_upgrade_id(upgrade: AbilityUpgrade):
	if upgrade.id == sword_amount.id:
		return sword.id
	elif upgrade.id == super_axe_amount.id:
		return super_axe.id
	elif upgrade.id == axe_amount.id:
		return axe.id
	elif upgrade.id == anvil_amount.id:
		return anvil.id
	return upgrade.id


func add_upgrade(upgrade: AbilityUpgrade):
	var upgrade_id = get_upgrade_id(upgrade)
	var upgrades = get_upgrades().filter(
		func(upgrade_in_list: UpgradeUI):
			return upgrade_in_list.upgrade_id == upgrade_id
	) as Array[UpgradeUI]
	if upgrades.size() == 0:
		var upgrade_instance = upgrade_ui_scene.instantiate() as UpgradeUI
		upgrade_instance.upgrade_id = upgrade_id
		upgrade_instance.image = upgrade.texture
		upgrade_instance.quantity = 1
		upgrades_container.add_child(upgrade_instance)
	else:
		var current_upgrade = upgrades[0] as UpgradeUI
		current_upgrade.update_quantity(current_upgrade.quantity + 1)


func remove_upgrade(upgrade: AbilityUpgrade):
	var upgrades = get_tree().get_nodes_in_group("upgrade_ui").filter(
		func(upgrade_in_list: UpgradeUI):
			return upgrade_in_list.upgrade_id == upgrade.id
	) as Array[UpgradeUI]
	if upgrades.size() == 0:
		return
	upgrades[0].queue_free()

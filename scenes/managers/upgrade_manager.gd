extends Node
class_name UpgradeManager

signal use_repelent
signal remove_ability

@export var experience_manager: ExperienceManager
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()
var can_level_up = true
var upgrades_count = 2
var rerolls: int = 0

var upgrade_refresh = preload("res://resources/upgrades/refresh_cards.tres")
var upgrade_get_vials = preload("res://resources/upgrades/get_vials.tres")
var upgrade_health_recovery = preload("res://resources/upgrades/health_recovery.tres")
var upgrade_sword = preload("res://resources/upgrades/sword.tres")
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_range = preload("res://resources/upgrades/sword_range.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_anvil = preload("res://resources/upgrades/anvil.tres")
var upgrade_anvil_amount = preload("res://resources/upgrades/anvil_amount.tres")
var upgrade_super_axe = preload("res://resources/upgrades/super_axe.tres")
var upgrade_super_axe_amount = preload("res://resources/upgrades/super_axe_amount.tres")
var upgrade_super_axe_speed = preload("res://resources/upgrades/super_axe_speed.tres")
var upgrade_repelent = preload("res://resources/upgrades/repelent.tres")

func _ready():
	upgrade_pool.add_item(upgrade_sword, 10)
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_anvil, 10)
	upgrade_pool.add_item(upgrade_player_speed, 10)
	upgrade_pool.add_item(upgrade_health_recovery, 10)
	upgrade_pool.add_item(upgrade_get_vials, 10)
	upgrade_pool.add_item(upgrade_repelent, 1)
	experience_manager.level_up.connect(on_level_up)
	if MetaProgression.save_data["meta_upgrades"].has("upgrades_quantity"):
		upgrades_count = 3
	if MetaProgression.save_data["meta_upgrades"].has("shuffle_upgrades"):
		rerolls = MetaProgression.save_data["meta_upgrades"]["shuffle_upgrades"]["quantity"]


func apply_upgrade(upgrade: AbilityUpgrade):	
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)
	if upgrade.id == upgrade_repelent.id:
		use_repelent.emit()
	
	if !upgrade.trackable:
		return
	
	var upgrades_ui = get_tree().get_first_node_in_group("upgrades_ui") as UpgradesUI
	if upgrades_ui == null:
		return
	upgrades_ui.add_upgrade(upgrade)
	


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_sword.id:
		upgrade_pool.add_item(upgrade_sword_rate, 10)
		upgrade_pool.add_item(upgrade_sword_range, 10)
		upgrade_pool.add_item(upgrade_sword_damage, 10)
	elif chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10)
	elif chosen_upgrade.id == upgrade_anvil.id:
		upgrade_pool.add_item(upgrade_anvil_amount, 10)
	elif chosen_upgrade.id == upgrade_axe_damage.id && current_upgrades[upgrade_axe_damage.id]["quantity"] == upgrade_axe_damage.max_quantity:
		upgrade_pool.add_item(upgrade_super_axe, 10000)
	elif chosen_upgrade.id == upgrade_super_axe.id:
		upgrade_pool.add_item(upgrade_super_axe_amount, 10)
		upgrade_pool.add_item(upgrade_super_axe_speed, 8)
		upgrade_pool.remove_item(upgrade_axe)
		upgrade_pool.remove_item(upgrade_axe_damage)
		remove_ability.emit(upgrade_axe)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in upgrades_count:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)
	
	if rerolls > 0:
		chosen_upgrades.append(upgrade_refresh)
	
	return chosen_upgrades


func on_upgrade_selected(upgrade: AbilityUpgrade):
	if upgrade.id == upgrade_refresh.id:
		rerolls -= 1
		refresh_upgrades()
	else:
		apply_upgrade(upgrade)


func refresh_upgrades():
	var upgrade_screen_instance = upgrade_screen_scene.instantiate() as UpgradeScreenUI
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades)
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func on_level_up(_new_level: int):
	if !can_level_up:
		return
	refresh_upgrades()

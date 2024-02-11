extends Node
class_name HealthComponent

signal died
signal health_changed
signal deal_damage

@export var max_health: float = 10

var current_health


func _ready():
	current_health = max_health


func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	deal_damage.emit()
	health_changed.emit()
	Callable(check_death).call_deferred()


func increase_health(amount_to_increase: float):
	if current_health == max_health || current_health <= 0:
		return
	current_health = min(current_health + amount_to_increase, max_health)
	health_changed.emit()


func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)


func check_death():
	if current_health == 0:
		die()
	

func die():
	died.emit()

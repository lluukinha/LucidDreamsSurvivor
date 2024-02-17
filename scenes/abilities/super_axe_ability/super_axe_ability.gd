extends Node2D
class_name SuperAxeAbility

const MAX_RADIUS = 80

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var base_rotation = Vector2.UP
var tween: Tween

func _ready():
	create_rotation()


func create_rotation():
	tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3.5)
	tween.tween_callback(create_rotation)


func tween_method(rotations: float):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var current_direction = base_rotation.rotated(rotations * TAU)

	global_position = player.global_position + (current_direction * MAX_RADIUS)

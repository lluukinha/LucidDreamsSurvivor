extends Node2D
class_name ExperienceVial

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

var collected = false

func _ready():
	$Area2D.area_entered.connect(on_area_entered)


func tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var direction_from_start = player.global_position - start_position
	global_position = start_position.lerp(player.global_position, percent)
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))
	if global_position == player.global_position:
		collect()


func collect():
	if collected:
		return
	collected = true
	GameEvents.emit_experience_vial_collected(1)
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true

func collect_vial(duration = .5):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, .05).set_delay(duration + .5)
	tween.chain()
	tween.tween_callback(collect)


func on_area_entered(_other_area: Area2D):
	collect_vial()

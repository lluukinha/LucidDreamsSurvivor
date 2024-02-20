extends Area2D
class_name Joystick

@onready var big_circle: Sprite2D = $BigCircle
@onready var small_circle: Sprite2D = $BigCircle/SmallCircle
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var max_distance = 0
var touched = false

func _ready():
	max_distance = collision_shape_2d.shape.radius
	big_circle.visible = false


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		touched = event.pressed
		big_circle.visible = touched
		
		if touched:
			big_circle.global_position = event.position
		else:
			small_circle.global_position = Vector2.ZERO


func _process(_delta):
	if touched:
		small_circle.global_position = get_global_mouse_position()
		small_circle.global_position = big_circle.global_position + (small_circle.global_position - big_circle.global_position).limit_length(max_distance)


func get_velocity():
	var joystick_velocity = Vector2.ZERO
	if touched:
		joystick_velocity.x = small_circle.position.x / max_distance
		joystick_velocity.y = small_circle.position.y / max_distance
	return joystick_velocity


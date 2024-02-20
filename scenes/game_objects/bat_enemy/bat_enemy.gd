extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var visuals = $Visuals
@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_timer: Timer = $VelocityTimer

var is_moving = false

@export var arena_difficulty_level: int = 0

func _ready():
	health_component.update_max_health(health_component.max_health + (arena_difficulty_level * .8))
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(queue_free)


func _process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func die():
	$HealthComponent.die()


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()


func on_velocity_timer_timeout():
	velocity_component.max_speed += 5

extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var visuals = $Visuals
@onready var health_component: HealthComponent = $HealthComponent


var is_moving = false


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(queue_free)


func _process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()


func die():
	$HealthComponent.die()

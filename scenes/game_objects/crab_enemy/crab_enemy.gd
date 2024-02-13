extends CharacterBody2D

@onready var visuals: Node2D = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var health_component: HealthComponent = $HealthComponent


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(queue_free)


func _process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.y)
	if move_sign != 0:
		visuals.scale = Vector2(1, move_sign)


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()


func die():
	$HealthComponent.die()


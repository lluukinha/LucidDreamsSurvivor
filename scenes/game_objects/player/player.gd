extends CharacterBody2D
class_name Player

signal player_died

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var health_regeneration_timer = $HealthRegenerationTimer

const BASE_HEALTH = 10

var number_colliding_bodies = 0
var base_speed = 0
var can_move = true
var is_dead = false

func _ready():
	var max_health_quantity = MetaProgression.get_upgrade_count("maximum_health")
	health_component.update_max_health(BASE_HEALTH + (max_health_quantity * 10))
	health_component.died.connect(on_player_died)
	base_speed = velocity_component.max_speed
	
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	health_component.deal_damage.connect(on_deal_damage)
	GameEvents.ability_upgrade_added.connect(on_hability_upgrade_added)
	update_health_display()
	
	if MetaProgression.save_data["meta_upgrades"].has("health_regeneration"):
		health_regeneration_timer.timeout.connect(on_health_regeneration_timer_timeout)
		health_regeneration_timer.start()


func _process(_delta):
	if is_dead:
		return
	
	var movement_vector = get_movement_vector()
	if can_move:
		var direction = movement_vector.normalized()
		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self)
	
	if can_move && (movement_vector.x != 0 || movement_vector.y != 0):
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func get_movement_vector():	
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)


func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped() || !health_component:
		return
	health_component.damage(1)
	damage_interval_timer.start()


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func set_sprite(new_texture: Texture2D):
	$Visuals/Sprite2D.texture = new_texture


func on_body_entered(_other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()


func on_body_exited(_other_body: Node2D):
	number_colliding_bodies -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_deal_damage():
	GameEvents.emit_player_damaged()
	$HitRandomStreamPlayer.play_random()

func on_health_changed():
	update_health_display()


func on_hability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var scene = (ability_upgrade as Ability).ability_controller_scene
		abilities.add_child(scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)


func on_health_regeneration_timer_timeout():
	if health_component == null:
		return
	var health_to_increase = MetaProgression.save_data["meta_upgrades"]["health_regeneration"]["quantity"]
	health_component.increase_health(health_to_increase)
	health_regeneration_timer.start()


func on_player_died():
	is_dead = true
	health_component.queue_free()
	abilities.queue_free()
	health_bar.queue_free()
	animation_player.play("RESET")
	await animation_player.animation_finished
	animation_player.play("death")
	player_died.emit()
	await animation_player.animation_finished
	queue_free()

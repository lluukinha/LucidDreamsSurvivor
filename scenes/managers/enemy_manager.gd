extends Node

const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer: Timer = $Timer

var base_spawn_time = 0
var enemies_table = WeightedTable.new()
var can_spawn = true
var number_to_spawn = 1


func _ready():
	enemies_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	var mask_bit = 1 << 0
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, mask_bit)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		# no collisions found
		if result.is_empty():
			break
		# found a colision, rotate spawn in 90 degrees and try again
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position


func on_timer_timeout():
	if !can_spawn:
		return
	
	timer.start()
	
	var enemies_on_scene = get_tree().get_nodes_in_group("enemy").size()
	if enemies_on_scene > 80:
		return
	
	for i in number_to_spawn:
		var enemy_scene = enemies_table.pick_item() as PackedScene
		var enemy = enemy_scene.instantiate() as Node2D
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (0.1 / 12) * arena_difficulty
	time_off = min(time_off, 0.7)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 8:
		enemies_table.add_item(wizard_enemy_scene, 15)
	elif arena_difficulty == 20:
		enemies_table.add_item(bat_enemy_scene, 7)
	
	if number_to_spawn < 5 && arena_difficulty > 18 && (arena_difficulty % 6) == 0:
		number_to_spawn +=1

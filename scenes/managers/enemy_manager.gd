extends Node

const SPAWN_RADIUS = 375

var crab_enemy_scene = preload("res://scenes/game_objects/crab_enemy/crab_enemy.tscn")
var basic_enemy_scene = preload("res://scenes/game_objects/basic_enemy/basic_enemy.tscn")
var wizard_enemy_scene = preload("res://scenes/game_objects/wizard_enemy/wizard_enemy.tscn")
var bat_enemy_scene = preload("res://scenes/game_objects/bat_enemy/bat_enemy.tscn")
var lizard_enemy_scene = preload("res://scenes/game_objects/lizard_enemy/lizard_enemy.tscn")
var red_rat_enemy_scene = preload("res://scenes/game_objects/red_rat_enemy/red_rat_enemy.tscn")
var spider_enemy_scene = preload("res://scenes/game_objects/spider_enemy/spider_enemy.tscn")
var mummy_enemy_scene = preload("res://scenes/game_objects/mummy_enemy/mummy_enemy.tscn")

@export var arena_time_manager: Node

@onready var timer: Timer = $Timer
@onready var respawn_timer = $RespawnTimer


var base_spawn_time = 0
var enemies_table = WeightedTable.new()
var can_spawn = true
var number_to_spawn = 1
var max_to_spawn = 10
var arena_difficulty_level: int = 0


func _ready():
	if GameEvents.selected_hero.id == "brocoleo":
		number_to_spawn = 3
		max_to_spawn = 11
	elif GameEvents.selected_hero.id == "brocoleo":
		number_to_spawn = 5
		max_to_spawn = 12
	
	enemies_table.add_item(basic_enemy_scene, 10)
	enemies_table.add_item(crab_enemy_scene, 9)

	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	respawn_timer.timeout.connect(on_respawn_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func spawn_enemy(enemyScene: PackedScene):
	var enemy = enemyScene.instantiate() as Node2D
	enemy.arena_difficulty_level = arena_difficulty_level
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	enemy.global_position = get_spawn_position()
	entities_layer.add_child(enemy)


func get_player_direction():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized().rotated(randf_range(-0.2, 0.2))
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	return direction


func get_spawn_position(random_direction: bool = false):
	var player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return Vector2.ZERO
		
	var direction = get_player_direction()
	if random_direction:
		direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var mask_bit = 1 << 0
	var spawn_position = Vector2.ZERO
	for i in 8:
		spawn_position = player.global_position + (direction * SPAWN_RADIUS)
		var additional_check_offset = direction * 20
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, mask_bit)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		# no collisions found
		if result.is_empty():
			break
		# found a colision, rotate spawn in 90 degrees and try again
		else:
			direction = direction.rotated(deg_to_rad(45))
			spawn_position = player.global_position + (direction * SPAWN_RADIUS)
	
	return spawn_position


func on_timer_timeout():
	timer.start()
	
	if !can_spawn:
		return
	
	var enemies_on_scene = get_tree().get_nodes_in_group("enemy") as Array[Node2D]
	if enemies_on_scene.size() > 120:
		return
	
	for i in number_to_spawn:
		spawn_enemy(enemies_table.pick_item())


func on_respawn_timer_timeout():
	respawn_timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Player
	var enemies_on_scene = get_tree().get_nodes_in_group("enemy") as Array[Node2D]
	
	if player == null || enemies_on_scene.size() == 0:
		return
	
	var enemies_far_away = enemies_on_scene.filter(
		func(enemy: Node2D):
			var distance = enemy.global_position.distance_to(player.global_position)
			return enemy.global_position.distance_to(player.global_position) > 400
	) as Array[Node2D]
	
	for enemy in enemies_far_away:
		enemy.set_global_position(get_spawn_position(true))


func on_arena_difficulty_increased(arena_difficulty: int):
	arena_difficulty_level = arena_difficulty
	var time_off = (0.1 / 12) * arena_difficulty
	time_off = min(time_off, 0.7)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 15:
		enemies_table.add_item(wizard_enemy_scene, 15)
	elif arena_difficulty == 30:
		enemies_table.add_item(bat_enemy_scene, 10)
	elif arena_difficulty == 45:
		enemies_table.add_item(spider_enemy_scene, 20)
	elif arena_difficulty == 60:
		enemies_table.add_item(red_rat_enemy_scene, 25)
	elif arena_difficulty == 75:
		enemies_table.add_item(mummy_enemy_scene, 30)
	elif arena_difficulty == 90:
		enemies_table.add_item(lizard_enemy_scene, 35)
	
	if number_to_spawn < max_to_spawn && (arena_difficulty % 6) == 0:
		number_to_spawn +=1

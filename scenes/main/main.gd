extends Node

@export var end_screen_scene: PackedScene

@onready var arena_time_manager = $ArenaTimeManager
@onready var player = %Player


var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	(player.health_component as HealthComponent).died.connect(on_player_died)
	arena_time_manager.arena_timeout.connect(on_arena_timeout)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()


func on_arena_timeout():
	player.can_move = false
	MusicPlayer.stop()
	get_tree().call_group("enemy", "die")
	$EnemyManager.can_spawn = false
	$UpgradeManager.can_level_up = false
	(arena_time_manager.timer as Timer).stop()
	collect_all_and_finish()


func collect_all_and_finish():
	var vials = get_tree().get_nodes_in_group("experience") as Array[ExperienceVial]
	if vials.is_empty():
		show_victory_screen()
	else:
		for vial in vials:
			vial.collect_vial(1.0)
		await get_tree().create_timer(1.0).timeout
		collect_all_and_finish()


func show_victory_screen():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	end_screen_instance.play_jingle(false)
	MetaProgression.save()

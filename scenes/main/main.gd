extends Node
class_name GameLevel

@onready var arena_time_manager: ArenaTimeManager = $ArenaTimeManager
@onready var player: Player = %Player
@onready var vignette: Vignette = $Vignette


var end_screen_scene = preload("res://scenes/ui/end_screen.tscn")
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	vignette.animation_player.play("RESET")
	player.player_died.connect(on_player_died)
	arena_time_manager.arena_timeout.connect(on_arena_timeout)
	set_hero(GameEvents.selected_hero)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func collect_all_vials():
	var vials = get_tree().get_nodes_in_group("experience") as Array[ExperienceVial]
	if vials.size() > 0:
		for vial in vials:
			vial.collect_vial(1.0)
		await get_tree().create_timer(1.0).timeout
		collect_all_vials()


func show_end_screen(player_died: bool):
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	if player_died:
		end_screen_instance.set_defeat()
	else:
		end_screen_instance.play_jingle(false)
		MetaProgression.level_up()

	MetaProgression.save()


func freeze_game():
	# player.can_move = false
	$MusicPlayer.stop()
	$EnemyManager.can_spawn = false
	$UpgradeManager.can_level_up = false


func set_hero(hero: HeroResource):
	player.set_sprite(hero.sprite)
	$UpgradeManager.apply_upgrade(hero.start_ability)


func on_player_died():
	freeze_game()
	vignette.on_game_over()
	await vignette.animation_player.animation_finished
	show_end_screen(true)


func on_arena_timeout():
	freeze_game()
	get_tree().call_group("enemy", "die")
	arena_time_manager.stop_timer()
	$ArenaTimeUI.visible = false
	collect_all_vials()
	await get_tree().create_timer(5.0).timeout
	show_end_screen(false)

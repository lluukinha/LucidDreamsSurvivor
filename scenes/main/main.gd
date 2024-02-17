extends Node
class_name GameLevel

@onready var arena_time_manager: ArenaTimeManager = $ArenaTimeManager
@onready var player: Player = %Player
@onready var vignette: Vignette = $Vignette
@onready var upgrade_manager: UpgradeManager = $UpgradeManager
@onready var upgrades_ui: UpgradesUI = $UpgradesUI
@onready var experience_manager: ExperienceManager = $ExperienceManager


var end_screen_scene = preload("res://scenes/ui/end_screen.tscn")
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var revives: int = 0

func _ready():
	vignette.animation_player.play("RESET")
	player.player_died.connect(on_player_died)
	arena_time_manager.arena_timeout.connect(on_arena_timeout)
	upgrade_manager.remove_ability.connect(on_remove_ability)
	player.collect_vials.connect(collect_all_vials)
	set_hero(GameEvents.selected_hero)
	
	if MetaProgression.save_data["meta_upgrades"].has("revive"):
		revives = MetaProgression.save_data["meta_upgrades"]["revive"]["quantity"]


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func collect_all_vials():
	var vials = get_tree().get_nodes_in_group("experience") as Array[ExperienceVial]
	if vials.size() > 0:
		for vial in vials:
			vial.collect_vial(.5)
		await get_tree().create_timer(1.0).timeout
		collect_all_vials()


func show_end_screen(player_died: bool, can_revive: bool = false):
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	end_screen_instance.can_revive = can_revive
	add_child(end_screen_instance)
	end_screen_instance.revive.connect(on_revive)
	if player_died:
		end_screen_instance.set_defeat()
	else:
		end_screen_instance.play_jingle(false)
		MetaProgression.level_up()


func on_revive():
	vignette.animation_player.play("RESET")
	revives -= 1
	$MusicPlayer.play()
	$EnemyManager.can_spawn = true
	$UpgradeManager.can_level_up = true
	player.can_attack = true
	player.revive()


func freeze_game():
	player.can_attack = false
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
	show_end_screen(true, revives > 0)


func on_arena_timeout():
	freeze_game()
	get_tree().call_group("enemy", "die")
	arena_time_manager.stop_timer()
	$ArenaTimeUI.visible = false
	collect_all_vials()
	await get_tree().create_timer(2.5).timeout
	show_end_screen(false, false)


func on_remove_ability(ability: AbilityUpgrade):
	player.remove_ability(ability)
	upgrades_ui.remove_upgrade(ability)

extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var meta_menu_scene = preload("res://scenes/ui/meta_menu.tscn")
var player_selection_scene = preload("res://scenes/ui/player_selection.tscn")


@onready var vignette: Vignette = $Vignette
@onready var margin_container = $MarginContainer

func _ready():
	%PlayButton.pressed.connect(on_play_pressed)
	%UpgradesButton.pressed.connect(on_upgrades_pressed)
	%OptionsButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)
	vignette.animation_player.play("RESET")


func on_play_pressed():
	margin_container.visible = false
	var player_selection_instance = player_selection_scene.instantiate()
	add_child(player_selection_instance)
	player_selection_instance.back_pressed.connect(on_back_pressed.bind(player_selection_instance))


func on_upgrades_pressed():
	margin_container.visible = false
	var meta_menu_instance = meta_menu_scene.instantiate()
	add_child(meta_menu_instance)
	meta_menu_instance.back_pressed.connect(on_back_pressed.bind(meta_menu_instance))
	#add_child()
	#ScreenTransition.transition_to_scene()


func on_options_pressed():
	margin_container.visible = false
	var options_instance = options_scene.instantiate() as OptionsMenu
	add_child(options_instance)
	options_instance.back_pressed.connect(on_back_pressed.bind(options_instance))


func on_back_pressed(instance: Node):
	margin_container.visible = true
	instance.queue_free()


func on_quit_pressed():
	get_tree().quit()

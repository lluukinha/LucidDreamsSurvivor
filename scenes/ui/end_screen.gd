extends CanvasLayer
class_name EndScreen

signal revive

@export var can_revive: bool = false

@onready var panel_container = %PanelContainer

func _ready():
	panel_container.pivot_offset = panel_container.size / 2
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	
	if can_revive:
		%ReviveButton.visible = true
		%ReviveButton.pressed.connect(on_revive_button_pressed)
	
	%QuitButton.pressed.connect(on_quit_button_pressed)


func set_defeat():
	%TitleLabel.text = tr("defeat_title")
	%DescriptionLabel.text = tr("defeat_description")
	play_jingle(true)


func play_jingle(defeat: bool):
	if defeat:
		$DefeatStreamPlayer.play()
	else:
		$VictoryStreamPlayer.play()


func on_quit_button_pressed():
	MetaProgression.save()
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")


func on_revive_button_pressed():
	revive.emit()
	get_tree().paused = false
	queue_free()

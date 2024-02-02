extends CanvasLayer

signal transitioned_halfway

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func transition():
	$ColorRect.visible = true
	animation_player.play("default")
	await animation_player.animation_finished
	emit_transitioned_halfway()
	animation_player.play_backwards("default")
	await animation_player.animation_finished
	$ColorRect.visible = false


func transition_to_scene(scene_path: String):
	transition()
	await transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)


func emit_transitioned_halfway():
	transitioned_halfway.emit()

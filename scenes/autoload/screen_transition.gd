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


func emit_transitioned_halfway():
	transitioned_halfway.emit()

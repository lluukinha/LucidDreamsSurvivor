extends CanvasLayer
class_name Vignette

@onready var animation_player = $AnimationPlayer

func _ready():
	GameEvents.player_damaged.connect(on_player_damaged)


func on_player_damaged():
	animation_player.play("hit")


func on_game_over():
	animation_player.play("game_over")

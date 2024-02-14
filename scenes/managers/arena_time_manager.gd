extends Node
class_name ArenaTimeManager

signal arena_difficulty_increased(arena_difficulty: int)
signal arena_timeout

const DIFFICULTY_INTERVAL = 5

@export var end_screen_scene: PackedScene
@export var arena_time_in_seconds: float = 600

@onready var timer: Timer = $Timer

var arena_difficulty: int = 0

func _ready():
	timer.set_wait_time(arena_time_in_seconds)
	timer.start()
	timer.timeout.connect(on_timer_timeout)


func _process(_delta):
	var next_time_target = timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)
	if timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)


func get_time_elapsed():
	return timer.wait_time - timer.time_left


func stop_timer():
	timer.stop()


func on_timer_timeout():
	arena_timeout.emit()

extends AudioStreamPlayer

@export var music_stream: AudioStream

func _ready():
	stream = music_stream
	finished.connect(on_finished)
	$Timer.timeout.connect(on_timer_timeout)
	play()


func on_finished():
	$Timer.start()


func on_timer_timeout():
	play()

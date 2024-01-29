extends Node2D


func get_end_position(multiply: int):
	return global_position + (Vector2.UP * multiply)


func start(text: String):
	$Label.text = text
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", get_end_position(16), .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_property(self, "global_position", get_end_position(48), .5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, .5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_callback(queue_free)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.5, .15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2.ONE, .15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	

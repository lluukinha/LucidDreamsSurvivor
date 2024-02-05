extends CanvasLayer

@export var experience_manager: ExperienceManager
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var label = %Label


func _ready():
	progress_bar.value = 0
	label.text = tr("level") + " " + str(experience_manager.current_level)
	experience_manager.experience_updated.connect(on_experience_updated)


func on_experience_updated(current: float, target: float):
	progress_bar.value = current / target
	label.text = tr("level") + " " + str(experience_manager.current_level)
	

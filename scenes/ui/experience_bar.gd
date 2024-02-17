extends CanvasLayer

@export var experience_manager: ExperienceManager

@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var label: Label = %Label
@onready var vials_count_label: Label = %VialsCountLabel
@onready var player_image: TextureRect = %PlayerImage

var experience_collected: int = 0

func _ready():
	progress_bar.value = 0
	label.text = tr("level") + " " + str(experience_manager.current_level)
	experience_manager.experience_updated.connect(on_experience_updated)
	vials_count_label.text = str(experience_collected)
	player_image.texture = GameEvents.selected_hero.sprite


func on_experience_updated(current: float, target: float):
	progress_bar.value = current / target
	label.text = tr("level") + " " + str(experience_manager.current_level)
	experience_collected += 1
	vials_count_label.text = str(experience_collected)
	
	

extends Node
class_name ExperienceManager

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

const TARGET_EXPERIENCE_GROWTH = 3

var current_experience = 0
var current_level = 1
var target_experience = TARGET_EXPERIENCE_GROWTH


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)


func on_experience_vial_collected(number: float):
	increment_experience(number)


func increment_experience(number: float):
	current_experience = min(current_experience + number, target_experience)
	experience_updated.emit(current_experience, target_experience)
	if current_experience == target_experience:
		update_level()


func update_level():
	current_level += 1
	target_experience += TARGET_EXPERIENCE_GROWTH
	current_experience = 0
	experience_updated.emit(current_experience, target_experience)
	level_up.emit(current_level)

extends CanvasLayer
class_name VialsCountUI

@export var vials: int = 0

@onready var label = $MarginContainer/HBoxContainer/Label


func _ready():
	label.text = str(vials)


func update_vials():
	vials += 1
	label.text = str(vials)

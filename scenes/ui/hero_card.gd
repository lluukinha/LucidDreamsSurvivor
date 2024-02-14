extends PanelContainer
class_name HeroCard

signal select

@export var hero: HeroResource

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var button = $VBoxContainer/SoundButton

func _ready():
	button.text = hero.name
	texture_rect.texture = hero.image
	button.pressed.connect(on_button_pressed)


func on_button_pressed():
	select.emit()

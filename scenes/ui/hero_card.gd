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
	
	var discovered_heroes = MetaProgression.save_data["discovered_heroes"] as Array[String]
	
	if !discovered_heroes.has(hero.id):
		set_modulate(Color.BLACK)
		button.disabled = true


func on_button_pressed():
	select.emit()

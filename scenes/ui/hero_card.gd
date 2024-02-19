extends PanelContainer
class_name HeroCard

signal select

@export var hero: HeroResource

@onready var texture_rect = $MarginContainer/TextureRect

var disabled = false

func _ready():
	gui_input.connect(on_gui_input)
	texture_rect.texture = hero.image
	
	var discovered_heroes = MetaProgression.save_data["discovered_heroes"] as Array[String]
	
	if !discovered_heroes.has(hero.id):
		set_modulate(Color.BLACK)
		disabled = true


func on_gui_input(event: InputEvent):
	if disabled:
		return
	
	if event.is_action_pressed("confirm") && !disabled:
		select.emit()

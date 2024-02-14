extends CanvasLayer

@onready var heroes_container = $MarginContainer/VBoxContainer/HeroesContainer
@onready var back_button = %BackButton

var morengo_hero = preload("res://resources/heroes/morengo.tres")
var cebolito_hero = preload("res://resources/heroes/cebolito.tres")
var brocoleo_hero = preload("res://resources/heroes/brocoleo.tres")

var heroes = [morengo_hero, cebolito_hero, brocoleo_hero]
var hero_card_scene = preload("res://scenes/ui/hero_card.tscn")

func _ready():
	back_button.pressed.connect(on_back_pressed)
	for hero in heroes:
		var hero_instance = hero_card_scene.instantiate() as HeroCard
		hero_instance.hero = hero
		heroes_container.add_child(hero_instance)
		hero_instance.select.connect(on_hero_selected.bind(hero))


func on_hero_selected(hero: HeroResource):
	GameEvents.select_hero(hero)
	ScreenTransition.transition_to_scene("res://scenes/main/main.tscn")


func on_back_pressed():
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")

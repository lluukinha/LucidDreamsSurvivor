extends CanvasLayer
class_name OptionsMenu

signal back_pressed

@onready var window_button: CheckButton = %WindowButton
@onready var language_button: OptionButton = %OptionButton
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var back_button = %BackButton


func _ready():
	back_button.pressed.connect(on_back_pressed)
	window_button.toggled.connect(on_window_button_toggled)
	language_button.item_selected.connect(on_language_selected)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	update_display()


func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func update_display():
	var window_mode = DisplayServer.window_get_mode()
	window_button.button_pressed = window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	if MetaProgression.save_data["language"] == "pt":
		language_button.selected = 1
	else:
		language_button.selected = 0
	
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")


func on_window_button_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func on_language_selected(index):
	var new_language = "en"
	if index == 1:
		new_language = "pt"
	MetaProgression.update_locale(new_language)


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)


func on_back_pressed():
	back_pressed.emit()


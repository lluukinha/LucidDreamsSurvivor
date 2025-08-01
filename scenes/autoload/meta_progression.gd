extends Node

const SAVE_FILE_PATH = "user://game.save"

var save_data: Dictionary = {
	"language": "en",
	"win_count": 0,
	"loss_count": 0,
	"meta_upgrade_currency": 0,
	"discovered_heroes": ["morengo"],
	"meta_upgrades": {}
}

func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	load_save_file()
	TranslationServer.set_locale(save_data["language"])


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()


func level_up():
	var current_hero = GameEvents.selected_hero as HeroResource
	if !save_data["discovered_heroes"].has("cebolito"):
		save_data["discovered_heroes"].append("cebolito")
	elif current_hero.id == 'cebolito' && !save_data["discovered_heroes"].has("brocoleo"):
		save_data["discovered_heroes"].append("brocoleo")


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)


func add_meta_upgrade(upgrade: MetaUpgrade):
	if !save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = { "quantity": 0 }
	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	
	save_data["meta_upgrade_currency"] -= upgrade.cost
	save()


func get_upgrade_count(upgrade_id: String):
	if save_data["meta_upgrades"].has(upgrade_id):
		return save_data["meta_upgrades"][upgrade_id]["quantity"]
	return 0


func update_locale(new_language: String):
	save_data["language"] = new_language
	TranslationServer.set_locale(new_language)
	save()
	

func on_experience_collected(number: float):
	save_data["meta_upgrade_currency"] += number

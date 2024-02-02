extends PanelContainer
class_name MetaUpgradeCard

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar = %ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label = %ProgressLabel

var meta_upgrade: MetaUpgrade

func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)


func set_meta_upgrade(upgrade: MetaUpgrade):
	meta_upgrade = upgrade
	name_label.text = tr(upgrade.title) 
	description_label.text = tr(upgrade.description)
	update_progress()


func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = currency / meta_upgrade.cost
	percent = min(percent, 1)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1
	progress_label.text = str(currency) + "/" + str(meta_upgrade.cost)


func on_purchase_pressed():
	if meta_upgrade == null:
		return
	MetaProgression.add_meta_upgrade(meta_upgrade)
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")

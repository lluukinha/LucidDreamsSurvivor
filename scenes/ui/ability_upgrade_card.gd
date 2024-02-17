extends PanelContainer
class_name AbilityUpgradeCard

signal selected

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ability_image: TextureRect = %AbilityImage


var disabled = false


func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func play_in(delay: float = 0.0):
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	animation_player.play("in")


func play_discard():
	animation_player.play("discard")


func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = tr(upgrade.name) 
	description_label.text = tr(upgrade.description)
	ability_image.texture = upgrade.texture


func select_card():
	disabled = true
	animation_player.play("selected")
	
	var other_cards = get_tree().get_nodes_in_group("upgrade_card")	
	for other_card in other_cards:
		if other_card == self:
			continue
		other_card.play_discard()
	
	await animation_player.animation_finished
	selected.emit()


func on_gui_input(event: InputEvent):
	if disabled:
		return
	
	if (event.is_action_pressed("confirm")):
		select_card()


func on_mouse_entered():
	if disabled:
		return
	$HoverAnimationPlayer.play("hover")


func on_mouse_exited():
	$HoverAnimationPlayer.play("RESET")


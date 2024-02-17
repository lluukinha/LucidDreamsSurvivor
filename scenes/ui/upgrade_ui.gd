extends HBoxContainer
class_name UpgradeUI

@export var quantity: int
@export var image: Texture2D
@export var upgrade_id: String

func _ready():
	($Image as TextureRect).texture = image
	($Label as Label).text = str(quantity) + "x"


func update_quantity(new_quantity: int):
	quantity = new_quantity
	($Label as Label).text = str(quantity) + "x"

extends Control


onready var title_label = $NinePatchRect/ItemNameLabel
onready var category_label = $NinePatchRect/CategoryLabel
onready var description_label = $NinePatchRect/DescriptionLabel


var title: String
var description: String
var category: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_info(
	item_name: String, 
	category: String, 
	description: String
):
	title_label.text = item_name
	category_label.text = category
	description_label.text = description


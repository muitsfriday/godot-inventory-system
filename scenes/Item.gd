extends Node2D

class_name DisplayItemStack

const SPRITE_PATH = "res://sprites/ui_item/%s.png"

onready var texture_placement = $TextureRect
onready var qty_counter = $Label

var item_code: String
var quantity: int


func _ready():
	invalidate()
	

# init item info into scene without invalidate it
func init(code, qty):
	self.item_code = code
	self.quantity = qty
	

# rerender the scene using held data
func invalidate():
	if item_code == "": 
		return
	texture_placement.texture = load(SPRITE_PATH % item_code)
	qty_counter.text = String(quantity)


# set item info into scene and invalidate it
func set_item(code, qty):
	init(code, qty)
	invalidate()


# increase the item quantity by a given qty
func inc_quantity(qty: int):
	self.quantity += qty
	invalidate()

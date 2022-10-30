extends Panel

var ItemScene = preload("res://scenes/Item.tscn")

var default_texture = preload("res://sprites/ui_inventory/inventory_slot.png")
var disabled_texture = preload("res://sprites/ui_inventory/inventory_slot_disabled.png")

var default_style: StyleBoxTexture = null
var disabled_style: StyleBoxTexture = null

var index: int
var item_scene: DisplayItemStack = null
var is_disabled = false setget set_disabled, get_disabled


func set_disabled(disabled: bool):
	is_disabled = disabled
	invalidate()
	
	
func get_disabled() -> bool:
	return is_disabled


func _ready():
	default_style = StyleBoxTexture.new()
	disabled_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	disabled_style.texture = disabled_texture


func invalidate():
	if is_disabled:
		set('custom_styles/panel', disabled_style)
	else:
		set('custom_styles/panel', default_style)


# set item into slot
# this will create the item scene and hyold it
func set_item(item_code: String, quantity: int):
	if item_scene == null:
		item_scene = ItemScene.instance()
		item_scene.init(item_code, quantity)
		add_child(item_scene)
		item_scene.position = Vector2(1, 1)
	else:
		item_scene.set_item(item_code, quantity)


# pick an item with a specific number.
# return Item that picked
# if all item is picked it will remove Item from child
func pick_some(qty: int) -> DisplayItemStack:
	var picked_qty = clamp(qty, 1, item_scene.quantity)
	
	# create item scene that will returns to user
	var picked_item = ItemScene.instance()
	picked_item.init(item_scene.item_code, picked_qty)
	
	item_scene.quantity -= picked_qty
	if item_scene.quantity == 0:
		remove_child(item_scene)
		
	return picked_item


# remove the item from slot
func remove_item():
	if item_scene != null:
		remove_child(item_scene)
		item_scene.queue_free()
		item_scene = null


# get item code contain in the slot
func get_item_code() -> String:
	return item_scene.item_code
	

# get item quantity in the slot
func get_quantity() -> int:
	return item_scene.quantity

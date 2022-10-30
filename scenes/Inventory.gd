extends Control

const Slot = preload("res://scenes/Slot.gd")
const ItemScene = preload("res://scenes/Item.tscn")

onready var inventory_container = $TextureRect/GridContainer
onready var inventory_slots = inventory_container.get_children()

onready var Inventory := PlayerInventory
onready var player_inventory = Inventory.inventory

onready var tooltips = $Tooltips

var holding_item: DisplayItemStack = null
var should_show_tooltips = false


func _ready():
	tooltips.visible = false
	for i in range(inventory_slots.size()):
		var slot = inventory_slots[i] as Slot
		slot.index = i # set slot index
		slot.connect("gui_input", self, "_on_Slot_gui_input", [slot]) # register gui_input event to each slot
		slot.connect("mouse_entered", self, "_on_Slot_mouse_entered", [slot])
		slot.connect("mouse_exited", self, "_on_Slot_mouse_exited", [slot])
	init_inventory()
	

func _input(event):
	# handle render holding item
	if holding_item != null && is_instance_valid(holding_item):
		holding_item.global_position = get_global_mouse_position() + Vector2(3, 3)
	
	tooltips.visible = holding_item == null && should_show_tooltips
	if tooltips.visible:
		tooltips.rect_global_position = get_global_mouse_position() + Vector2(3, 3)



# init inventory be iterate through the slot
# and find the player inventory in a given index
func init_inventory():
	# render each slot that have an item in player inventory
	for i in range(inventory_slots.size()):
		(inventory_slots[i] as Slot).is_disabled = i >= Inventory.max_inventory
		if player_inventory.has(i):
			invalidate_slot(i)


# force rerender a given item slot
func invalidate_slot(index: int):
	if player_inventory.has(index):
		var item = Inventory.get_item(index)
		(inventory_slots[index] as Slot).set_item(
			item[Inventory.COL.CODE], 
			item[Inventory.COL.QTY]
		)
	else:
		(inventory_slots[index] as Slot).remove_item()
	

# set new holding item
func set_holding_item(item_code: String, quantity: int):
	# drop old one
	if holding_item != null:
		drop_holding_item()
	
	# create new one
	var item = ItemScene.instance() as DisplayItemStack
	add_child(item)
	item.set_item(item_code, quantity)
	holding_item = item
	holding_item.global_position = get_global_mouse_position() + Vector2(3, 3)
	

# drop all item holding
func drop_holding_item():
	if holding_item == null: return
	remove_child(holding_item)
	holding_item.queue_free()
	holding_item = null


# increase holding quantity be a specific number
func inc_holding_quantity_by(quantity: int):
	if holding_item == null: return
	holding_item.quantity += quantity
	holding_item.invalidate()
	if holding_item.quantity <= 0:
		remove_child(holding_item)
		holding_item.queue_free()
		holding_item = null


# hold item from a slot
func hold_all_from_slot(slot: Slot):
	var slot_index = slot.get_index()
	var prev = Inventory.remove_item(slot_index)
	if prev == PlayerInventory.EMPTY_ITEM: 
		return
		
	set_holding_item(
		prev[PlayerInventory.COL.CODE], 
		prev[PlayerInventory.COL.QTY]
	)
	invalidate_slot(slot_index)


# hold item from a slot with a specific number of item
func hold_from_slot(slot: Slot, qty: int):
	var slot_index = slot.get_index()
	var inv_item = Inventory.get_item(slot_index)
	
	if inv_item == null: return
	var inv_item_code = inv_item[PlayerInventory.COL.CODE]
	
	# remove item from inv as eual as requested
	if !Inventory.remove_item_from(slot_index, qty):
		return
	
	# if holding is empty you can hold the item without condition
	if holding_item == null:
		set_holding_item(inv_item_code, qty)
	elif holding_item.item_code == inv_item_code:
		inc_holding_quantity_by(qty)
		
	invalidate_slot(slot_index)



# place the holding item into a specific slot
func place_held_item_to_slot(slot: Slot):
	var slot_index = slot.get_index()
	if holding_item == null: return
	
	var is_slot_empty = Inventory.get_item(slot_index) == null
	
	# remove currently hold item
	if holding_item.item_code == Inventory.get_item_code(slot_index):
		var leftover = Inventory.stack_item_to(
			slot_index, 
			holding_item.item_code, 
			holding_item.quantity
		)
		inc_holding_quantity_by(-1 * (holding_item.quantity - leftover))
	elif is_slot_empty:
		Inventory.add_item_to(
			slot_index, 
			holding_item.item_code, 
			holding_item.quantity
		)
		drop_holding_item()
	elif !is_slot_empty:
		var spare_holding = holding_item
		hold_all_from_slot(slot)
		Inventory.add_item_to(
			slot_index, 
			spare_holding.item_code, 
			spare_holding.quantity
		)
	invalidate_slot(slot_index)



func hold_half_stack(slot: Slot):
	var slot_index = slot.get_index()
	var inv_item = Inventory.get_item(slot_index)
	var inv_item_qty = inv_item[Inventory.COL.QTY]
	
	if inv_item == null: return
	return hold_from_slot(slot, max(floor(inv_item_qty / 2), 1))



func _on_Slot_gui_input(event: InputEvent, slot: Slot):
	if event is InputEventMouseButton:
		if slot.is_disabled: 
			return
			
		if event.pressed && event.button_index == BUTTON_LEFT:
			if holding_item == null:
				hold_all_from_slot(slot)
			else:
				place_held_item_to_slot(slot)
		elif event.pressed && event.button_index == BUTTON_RIGHT:
			if Input.is_action_pressed("shift"):
				hold_half_stack(slot)
			else:
				hold_from_slot(slot, 1)



func _on_Slot_mouse_entered(slot: Slot):
	var index = slot.index
	var item = Inventory.get_item(index)
	if item == null: return
	var info = ItemDB.get_item_info(item[PlayerInventory.COL.CODE])
	tooltips.set_info(
		info.name,
		info.category,
		info.description
	)
	should_show_tooltips = true
	


func _on_Slot_mouse_exited(slot: Slot):
	should_show_tooltips = false


extends Node

enum COL {
	CODE = 0
	QTY = 1
}

const EMPTY_CODE = "EMPTY"
const EMPTY_ITEM = [EMPTY_CODE, 0]

# the inventory keep data in a array pair [item_code, quantity]
var max_inventory = 20
var inventory = {
	0: ["dummy", 1],
	2: ["dummy2", 1],
	11: ["dummy2", 12],
	13: ["dummy2", 30]
}

# add item to inventory
# returns number indicate the leftover item quantity
func add_item(item_code: String, quantity: int) -> int:
	var info = ItemDB.get_item_info(item_code)
	if info == null: return quantity
	
	var stack_size = info.stack_size
	# try to add item to the current exists stack
	for i in inventory:
		if inventory[i][COL.CODE] == item_code:
			var free_space = stack_size - inventory[i][COL.QTY]
			if free_space >= quantity:
				inventory[i][COL.QTY] += quantity
				return 0
			else:
				inventory[i][COL.QTY] += free_space
				quantity -= free_space
	# add item to the empty space
	for i in range(max_inventory):
		if inventory.has(i) == false:
			var free_space = stack_size
			if free_space >= quantity:
				inventory[i] = [item_code, quantity]
				return 0
			else:
				inventory[i] = [item_code, stack_size]
				quantity -= free_space
			
	return quantity
	
	
# add item to a specific slot of inventory
# return true if it can place into a given index
func add_item_to(index: int, item_code: String, quantity: int) -> bool:
	var info = ItemDB.get_item_info(item_code)
	if info == null: return false
	if index >= max_inventory: return false
	
	var stack_size = info.stack_size
	var is_not_empty_slot = inventory.has(index)
	# if item exists in inventory and has matched item code
	# then check for free space to attemp to add the item in
	if is_not_empty_slot && inventory[index][COL.CODE] == item_code:
		var free_space = stack_size - inventory[index][COL.QTY]
		if free_space >= quantity:
			inventory[index][COL.QTY] += quantity
			return true
	# if item didnt exists just check the stack size
	elif !is_not_empty_slot:
		if stack_size >= quantity:
			inventory[index] = [item_code, quantity]
			return true
	return false
	
# try to merge a specific item into current stack
# return the leftover number
func stack_item_to(index: int, item_code: String, quantity: int) -> int:
	var info = ItemDB.get_item_info(item_code)
	if info == null: return quantity
	if index >= max_inventory: return quantity
	
	var stack_size = info.stack_size
	if !inventory.has(index): return quantity
	if inventory[index][COL.CODE] != item_code: return quantity
	
	var free_space = stack_size - inventory[index][COL.QTY]
	if free_space >= quantity:
		inventory[index][COL.QTY] += quantity
		return 0
	else:
		inventory[index][COL.QTY] = stack_size
		return quantity - free_space
	


func remove_item_from(index: int, qty: int) -> bool:
	if index >= max_inventory: return false
	
	if !inventory.has(index):
		return false
	
	if inventory[index][COL.QTY] < qty: 
		return false
	
	inventory[index][COL.QTY] -= qty
	if inventory[index][COL.QTY] <= 0:
		inventory.erase(index)
	return true
	
# remove item from inventory
# returns item that is removed
# returns EMPTY_ITEM if the inventory slot is empty
func remove_item(index: int) -> Array:
	if index >= max_inventory: 
		return EMPTY_ITEM
	
	if !inventory.has(index):
		return EMPTY_ITEM
	
	var prev = inventory[index]
	inventory.erase(index)
	return prev
	

func get_item(index: int) -> Array:
	return inventory[index] if inventory.has(index) else null


func get_item_code(index: int) -> String:
	return inventory[index][COL.CODE] if inventory.has(index) else EMPTY_CODE

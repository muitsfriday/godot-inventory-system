extends Node

# csv columns name
const COL_ID = "id"
const COL_ITEM_CODE = "item_code"
const COL_STACK_SIZE = "stack_size"
const COL_NAME = "name"
const COL_DESCRIPTION = "description"
const COL_CATEGORY = "category"

const DB_FILE_PATH = "res://db/items_db.json"
const ITEM_KEY_COL = COL_ITEM_CODE

class ItemInfo:
	var id: String
	var code: String
	var name: String
	var category: String
	var description: String
	var stack_size: int
		
var db: Dictionary

func _ready():
	db = load_items_db(DB_FILE_PATH)


func load_items_db(path: String):
	var data: Dictionary = {}
	var file = File.new()
	
	file.open(path, File.READ)
	var content = file.get_as_text()
	var item_list = JSON.parse(content)
	if typeof(item_list.result) != TYPE_ARRAY:
		return {}
	
	for item in item_list.result:
		var item_code = item[ITEM_KEY_COL]
		data[item_code] = item
		
	file.close()
	return data


# get item info by key
# returns item infor of a given item key
# return null if key not found
func get_item_info(key: String) -> ItemInfo:
	if !db.has(key): return null
	
	var row = db[key]
	var item = ItemInfo.new()
	item.id = row[COL_ID]
	item.code = row[COL_ITEM_CODE]
	item.name = row[COL_NAME]
	item.category = row[COL_CATEGORY]
	item.description = row[COL_DESCRIPTION]
	item.stack_size = row[COL_STACK_SIZE]
	return item

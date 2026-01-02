extends SerializableNode2D
class_name ItemsList

var items: Dictionary[String, Item]

var layer: Layer


func _init(_layer: Layer):
	layer = _layer


func get_item(pos: Vector2i) -> Item:
	return items.get(Utils.vector2i_to_string(pos))


## Return if the item was drop or not.
func add_item(item: Item) -> bool:
	var pos_key: String = Utils.vector2i_to_string(item.grid_position)

	if items.has(pos_key):
		Utils.print_warning("An item already exists in the position (%s)" % pos_key)
		return false
	items[pos_key] = item

	if item.get_parent():
		item.reparent(self)
	else:
		add_child(item)

	return true

## Returns if the item was remove or not.
func erase_item(pos: Vector2i) -> bool:
	var pos_key: String = Utils.vector2i_to_string(pos)

	if items.has(pos_key):
		items.erase(pos_key)
		return true
	else:
		return false

################################################################################
# Serialization
################################################################################
func load(data: Dictionary) -> void:
	super.load(data)
	for item_key in data:
		var item_data: Dictionary = data[item_key]
		var grid_position: Vector2i = Utils.string_to_vector2i(item_key)
		item_data["grid_position"] = {
			x = grid_position.x,
			y = grid_position.y
		}
		var item: Item

		if not item_data.has("type"):
			item_data["type"] = "default"
		
		match Utils.string_to_item_type(item_data["type"]):
			Globals.ItemType.HEALING_POTION:
				item = HealingPotion.new(layer)
			Globals.ItemType.MELEE_WEAPON:
				item = MeleeWeapon.new(layer)
			_:
				item = Item.new(layer)

		item.load(item_data)
		add_item(item)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

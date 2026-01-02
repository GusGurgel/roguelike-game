extends SerializableNode2D
class_name ItemsList

var items: Dictionary[String, Item]

var layer: Layer


func _init(_layer: Layer):
	layer = _layer

func get_item(pos: Vector2i) -> Item:
	return items.get(Utils.vector2i_to_string(pos))


func add_item(item: Item) -> void:
	var pos_key: String = Utils.vector2i_to_string(item.grid_position)

	if items.has(pos_key):
		Utils.print_warning("An item already exists in the position (%s)" % pos_key)
		return
	items[pos_key] = item

	if item.get_parent():
		item.reparent(self)
	else:
		add_child(item)


func load(data: Dictionary) -> void:
	super.load(data)
	for item_key in data:
		var item: Item = Item.new()
		var item_data: Dictionary = data[item_key]
		var grid_position: Vector2i = Utils.string_to_vector2i(item_key)
		item_data["grid_position"] = {
			x = grid_position.x,
			y = grid_position.y
		}
		item.load(item_data)
		add_item(item)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

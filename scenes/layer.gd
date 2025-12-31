extends SerializableNode2D
class_name Layer
## Represents a Game layer, contais the tiles and entities.

var tiles: TileList
var entities: EntityList
var itens: Dictionary[String, Item]

var astar_grid: AStarGrid2D = AStarGrid2D.new()

@onready var entities_child = $Entities
@onready var itens_child = $Itens

var top_left: Vector2i:
	set(value):
		top_left = value
		_update_astar_region()


var bottom_right: Vector2i:
	set(value):
		bottom_right = value
		_update_astar_region()


func _ready() -> void:
	# Add items.
	for item: Item in itens.values():
		if item.get_parent():
			item.reparent(itens_child)
		else:
			itens_child.add_child(item)
	

## Return all tiles of a grid_position. Including basic tiles and entity tiles.
func get_tiles(pos: Vector2i) -> Array[Tile]:
	var tiles_arr: Array[Tile] = []

	var string_pos: String = Utils.vector2i_to_string(pos)

	var tile: Variant = tiles.get_tile(pos)
	var entity: Variant = entities.get_entity(pos)
	var item: Variant = itens.get(string_pos)


	if tile != null and is_instance_valid(tile):
		tile = tile as Tile
		if tile:
			tiles_arr.push_back(tile)
	
	
	if entity != null and is_instance_valid(entity):
		entity = entity as Entity
		if entity:
			tiles_arr.push_back(entity)


	if item != null and is_instance_valid(item):
		item = item as Item
		if item:
			tiles_arr.push_back(item)


	return tiles_arr

	
## Return true if erased, else false.
func erase_tile(pos: Vector2i) -> bool:
	var pos_key: String = Utils.vector2i_to_string(pos)

	if tiles.has(pos_key):
		tiles[pos_key].queue_free()
		tiles.erase(pos_key)
		return true
	return false


## Return true if item was set, else false
func set_item(item: Item) -> bool:
	var pos_key: String = Utils.vector2i_to_string(item.grid_position)

	if itens.get(pos_key) != null:
		return false
	
	itens[pos_key] = item
	## Add tile or reparent to the current layer.
	if item.get_parent():
		item.reparent(itens_child)
	else:
		itens_child.add_child(item)
	
	return true


func erase_item(pos: Vector2i, free_item_node: bool = false) -> void:
	var pos_key: String = Utils.vector2i_to_string(pos)

	if itens.has(pos_key):
		if free_item_node:
			itens[pos_key].queue_free()
		itens.erase(pos_key)


func _update_astar_region() -> void:
	var size = (bottom_right - top_left).abs() + Vector2i.ONE
	
	astar_grid.region = Rect2i(top_left, size)
	
	astar_grid.update()


# func get_tiles_as_dict() -> Dictionary:
# 	var result: Dictionary = {}

# 	for tile_key in self.tiles:
# 		result[tile_key] = self.tiles[tile_key].get_as_dict()

# 	return result


## Return if it's possible to move to pos.
func can_move_to_position(pos: Vector2i) -> bool:
	var pos_tiles: Array[Tile] = get_tiles(pos)
	return not Utils.any_of_array_has_propriety_with_value(pos_tiles, "has_collision", true)


func load(data: Dictionary) -> void:
	super.load(data)

	astar_grid.update()

	tiles = TileList.new(astar_grid)
	tiles.load(data["tiles"])
	tiles.name = "Tiles"
	add_child(tiles)
	move_child(tiles, 0)

	entities = EntityList.new(astar_grid)
	entities.load(data["entities"])
	add_child(entities)
	move_child(entities, 1)
	

func serialize() -> Dictionary:
	var result: Dictionary = {}
	return result

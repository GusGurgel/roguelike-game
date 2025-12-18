extends Node2D
class_name Layer
## Represents a Game layer, contais the tiles and entities.

var tiles: Dictionary[String, Tile]
var entities: Dictionary[String, Entity]
var itens: Dictionary[String, Item]

var astar_grid = AStarGrid2D.new()

@onready var tiles_child = $Tiles
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
	var first_pos: Vector2i = tiles.values()[0].grid_position
	
	var temp_top_left = first_pos
	var temp_bottom_right = first_pos

	# Add tiles.
	for tile: Tile in tiles.values():
		if tile.get_parent():
			tile.reparent(tiles_child)
		else:
			tiles_child.add_child(tile)
		
		temp_top_left = temp_top_left.min(tile.grid_position)
		temp_bottom_right = temp_bottom_right.max(tile.grid_position)

	# Update astar region.
	top_left = temp_top_left
	bottom_right = temp_bottom_right

	# Set solid on astar_grid.
	for tile: Tile in tiles.values():
		astar_grid.set_point_solid(tile.grid_position, tile.has_collision)
		
	# Add entities.
	for entity: Entity in entities.values():
		if entity.get_parent():
			entity.reparent(entities_child)
		else:
			entities_child.add_child(entity)
	
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

	var tile: Variant = tiles.get(string_pos)
	var entity: Variant = entities.get(string_pos)
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

func set_tile(tile: Tile) -> void:
	var pos_key: String = Utils.vector2i_to_string(tile.grid_position)

	erase_tile(tile.grid_position)
	tiles[pos_key] = tile
	## Add tile or reparent to the current layer.
	if tile.get_parent():
		tile.reparent(tiles_child)
	else:
		tiles_child.add_child(tile)

	## Update Top Left and Top Right.
	top_left = top_left.min(tile.grid_position)
	bottom_right = bottom_right.max(tile.grid_position)

	
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


func get_tiles_as_dict() -> Dictionary:
	var result: Dictionary = {}

	for tile_key in self.tiles:
		result[tile_key] = self.tiles[tile_key].get_as_dict()

	return result


## Return if it's possible to move to pos.
func can_move_to_position(pos: Vector2i) -> bool:
	var pos_tiles: Array[Tile] = get_tiles(pos)
	return not Utils.any_of_array_has_propriety_with_value(pos_tiles, "has_collision", true)

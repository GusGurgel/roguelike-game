extends SerializableNode2D
class_name Layer
## Represents a Game layer, contais the tiles and entities.

var astar_grid: AStarGrid2D = AStarGrid2D.new()

var tiles: TileList = TileList.new(astar_grid)
var entities: EntityList = EntityList.new(astar_grid)
var items: ItemsList = ItemsList.new()


## Return all tiles of a grid_position. Including basic tiles and entity tiles.
func get_tiles(pos: Vector2i) -> Array[Tile]:
	var tiles_arr: Array[Tile] = []

	var tile: Variant = tiles.get_tile(pos) as Tile
	var entity: Variant = entities.get_entity(pos) as Entity
	var item: Variant = items.get_item(pos) as Item


	if is_instance_valid(tile):
		tiles_arr.push_back(tile)
	
	
	if is_instance_valid(entity):
		tiles_arr.push_back(entity)


	if is_instance_valid(item):
		tiles_arr.push_back(item)


	return tiles_arr


## Return if it's possible to move to pos.
func can_move_to_position(pos: Vector2i) -> bool:
	var pos_tiles: Array[Tile] = get_tiles(pos)
	return not Utils.any_of_array_has_propriety_with_value(pos_tiles, "has_collision", true)


func load(data: Dictionary) -> void:
	super.load(data)
	
	astar_grid.update()

	tiles.load(data["tiles"])
	tiles.name = "Tiles"
	add_child(tiles)
	move_child(tiles, 0)

	entities.load(data["entities"])
	entities.name = "Entities"
	add_child(entities)
	move_child(entities, 1)

	items.load(data["items"])
	items.name = "Items"
	add_child(items)
	move_child(items, 2)
	

func serialize() -> Dictionary:
	var result: Dictionary = {}
	return result

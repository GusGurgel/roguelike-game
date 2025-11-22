extends Node2D
class_name Layer
## Represents a Game layer, contais the tiles and entities.

var tiles: Dictionary[String, Tile]
@onready var tiles_node: Node2D = $Tiles

func _ready():
	for tile_key in tiles:
		tiles_node.add_child(tiles[tile_key])
	

## Return null if not exists
func get_tile(pos: Vector2i) -> Tile:
	return tiles.get(vector2i_to_string_key(pos))


func set_tile(tile: Tile) -> void:
	var pos_key: String = vector2i_to_string_key(tile.grid_position)

	erase_tile(tile.grid_position)
	tiles[pos_key] = tile
	add_child(tile)

	
## Return true if erased, else false
func erase_tile(pos: Vector2i) -> bool:
	var pos_key: String = vector2i_to_string_key(pos)

	if tiles.has(pos_key):
		tiles[pos_key].queue_free()
		tiles.erase(pos_key)
		return true
	return false


func vector2i_to_string_key(pos: Vector2i) -> String:
	return "%s,%s" % [pos.x, pos.y]
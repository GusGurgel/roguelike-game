extends Node2D
class_name Layer
## Represents a Game layer, contais the tiles and entities.

var tiles: Dictionary[String, Tile]
var entities: Dictionary[String, Entity]

@onready var tiles_child = $Tiles
@onready var entities_child = $Entities


func _ready():
	## Add tiles
	for tile_key in tiles:
		var tile: Tile = tiles[tile_key]

		if tile.get_parent():
			tile.reparent(tiles_child)
		else:
			tiles_child.add_child(tile)

	## Add entities
	for entity_key in entities:
		var entity: Entity = entities[entity_key]

		if entity.get_parent():
			entity.reparent(entities_child)
		else:
			entities_child.add_child(entity)
	

## Return all tiles of a grid_position. Including basic tiles and entity tiles
func get_tiles(pos: Vector2i) -> Array[Tile]:
	return [
		tiles.get(vector2i_to_string_key(pos)),
		entities.get(vector2i_to_string_key(pos))
	]


func set_tile(tile: Tile) -> void:
	var pos_key: String = vector2i_to_string_key(tile.grid_position)

	erase_tile(tile.grid_position)
	tiles[pos_key] = tile
	## Add tile or reparent to the current layer
	if tile.get_parent():
		tile.reparent(self)
	else:
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


func get_tiles_as_dict() -> Dictionary:
	var result: Dictionary = {}

	for tile_key in self.tiles:
		result[tile_key] = self.tiles[tile_key].get_as_dict()

	return result

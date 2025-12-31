extends SerializableNode2D
class_name EntityList

var entities: Dictionary[String, Entity]
var astar_grid: AStarGrid2D


func _init(_astar_grid: AStarGrid2D):
	astar_grid = _astar_grid


func get_entity(pos: Vector2i) -> Entity:
	return entities.get(Utils.vector2i_to_string(pos))


# func set_tile(tile: Tile) -> void:
# 	var pos_key: String = Utils.vector2i_to_string(tile.grid_position)

# 	if tiles.has(pos_key):
# 		erase_tile(tile.grid_position)
# 	tiles[pos_key] = tile

# 	## Add tile or reparent to the current layer.
# 	if tile.get_parent():
# 		tile.reparent(self)
# 	else:
# 		add_child(tile)

# 	## Update Top Left and Top Right.
# 	astar_grid.region = astar_grid.region.expand(tile.grid_position + Vector2i.ONE)
# 	astar_grid.update()
# 	astar_grid.set_point_solid(tile.grid_position, tile.has_collision)

func add_entity(entity: Entity) -> void:
	var pos_key: String = Utils.vector2i_to_string(entity.grid_position)

	if entities.has(pos_key):
		# erase_tile(tile.grid_position)
		Utils.print_warning("An entity already exists in the position (%s)" % pos_key)
		return
	entities[pos_key] = entity

	## Add tile or reparent to the current layer.
	if entity.get_parent():
		entity.reparent(self)
	else:
		add_child(entity)

	## Update Top Left and Top Right.
	astar_grid.region = astar_grid.region.expand(entity.grid_position + Vector2i.ONE)
	astar_grid.update()
	astar_grid.set_point_solid(entity.grid_position, true)


func load(data: Dictionary) -> void:
	for entity_key in data:
		var entity: Entity = Entity.new()
		var entity_data: Dictionary = data[entity_key]
		var grid_position: Vector2i = Utils.string_to_vector2i(entity_key)
		entity_data["grid_position"] = {
			x = grid_position.x,
			y = grid_position.y
		}
		entity.load(entity_data)
		add_entity(entity)


func serialize() -> Dictionary:
	var result: Dictionary = {}
	return result

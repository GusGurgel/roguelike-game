extends SerializableNode2D
class_name EntityList

var entities: Dictionary[String, Entity]

var layer: Layer


func _init(_layer: Layer):
	layer = _layer


func get_entity(pos: Vector2i) -> Entity:
	var entity = entities.get(Utils.vector2i_to_string(pos))

	if is_instance_valid(entity):
		return entity
	else:
		return null


func add_entity(entity: Entity) -> void:
	var pos_key: String = Utils.vector2i_to_string(entity.grid_position)

	if entities.has(pos_key):
		Utils.print_warning("An entity already exists in the position (%s)" % pos_key)
		return
	entities[pos_key] = entity

	if entity.get_parent():
		entity.reparent(self)
	else:
		add_child(entity)

	layer.astar_grid.set_point_solid(entity.grid_position, true)


func alert_entities_new_turn(old_turn: int, new_turn: int) -> void:
	for entity in entities.values():
		if is_instance_valid(entity):
			entity._on_turn_updated(old_turn, new_turn)

################################################################################
# Serialization
################################################################################

func load(data: Dictionary) -> void:
	super.load(data)

	for entity_key in data:
		var entity_data: Dictionary = data[entity_key]
		var grid_position: Vector2i = Utils.string_to_vector2i(entity_key)
		entity_data["grid_position"] = {
			x = grid_position.x,
			y = grid_position.y
		}
		var entity: Entity

		if not entity_data.has("type"):
			entity_data["type"] = "default"

		match Utils.string_to_enemy_type(entity_data["type"]):
			Globals.EntityType.ENEMY:
				entity = Enemy.new(layer)
			_:
				entity = Entity.new(layer)
			

		entity.load(entity_data)
		add_entity(entity)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

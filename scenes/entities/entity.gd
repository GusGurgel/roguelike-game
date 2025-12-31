extends Tile
class_name Entity


@export var max_health: int = 100:
	set(new_max_health):
		if new_max_health < 1:
			new_max_health = 1
		max_health = new_max_health

@export var health: int = 100:
	set(new_health):
		if new_health > max_health:
			health = max_health
		else:
			health = new_health

@export var max_mana: int = 100:
	set(new_max_mana):
		if new_max_mana < 1:
			new_max_mana = 1
		max_mana = new_max_mana

@export var mana: int = 100:
	set(new_mana):
		if new_mana > max_mana:
			mana = max_mana
		else:
			mana = new_mana

@export var entity_name: String = ""

@export var base_damage: int = 0

@export var turns_to_move: int = 1

## Reference to the entity layer
@export var layer: Layer = null


func _ready() -> void:
	super._ready()

	# This prevents the player to see moving explored entities
	if not is_in_view:
		visible = false


func get_as_dict(_return_grid_position: bool = true) -> Dictionary:
	return {
		tile = super.get_as_dict(true),
		name = self.name
	}


## Callback called when the enters the field of view of the player.
func _on_field_of_view_enter() -> void:
	grid_position = grid_position


## Callback called when the entity exits the field of view of the player.
func _on_field_of_view_exit() -> void:
	pass


## Callback called when the game turn is changed.
func _on_turn_updated(old_turn: int, new_turn: int) -> void:
	pass


## Hit the current entity, return if the entity die true if the entity die.
func get_hit(entity: Entity, damage: int) -> bool:
	self.health -= damage

	if self.health <= 0:
		kill()
		return true
	else:
		return false


## Get the entity damage
func get_damage() -> int:
	return base_damage


## Basic kill function. Just remove the node from the scene.
func kill() -> void:
	queue_free()


## Move the entity avoiding
func move_to(pos: Vector2i) -> void:
	pass
	# var grid_position_string: String = Utils.vector2i_to_string(self.grid_position)
	# var pos_string: String = Utils.vector2i_to_string(pos)

	# if layer.can_move_to_position(pos) \
	# and layer.entities.get(pos_string) == null:
	# 	layer.entities.erase(grid_position_string)
	# 	layer.entities.set(pos_string, self)
	# 	self.grid_position = pos

func load(data: Dictionary) -> void:
	super.load(data)
	Utils.copy_from_dict_if_exists(
		self,
		data,
		[
			"entity_name",
			"max_health",
			"health",
			"max_mana",
			"mana",
			"base_damage",
			"turns_to_move"
		]
	)

	is_transparent = true

func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

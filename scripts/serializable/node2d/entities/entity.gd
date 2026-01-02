extends Tile
class_name Entity


var max_health: int = 100:
	set(new_max_health):
		if new_max_health < 1:
			new_max_health = 1
		max_health = new_max_health

var health: int = 100:
	set(new_health):
		if new_health > max_health:
			health = max_health
		else:
			health = new_health

var max_mana: int = 100:
	set(new_max_mana):
		if new_max_mana < 1:
			new_max_mana = 1
		max_mana = new_max_mana

var mana: int = 100:
	set(new_mana):
		if new_mana > max_mana:
			mana = max_mana
		else:
			mana = new_mana

var entity_name: String = ""

var base_damage: int = 0

var turns_to_move: int = 1

var layer: Layer


func _init(_layer: Layer):
	layer = _layer


## Callback called when the enters the field of view of the player.
func _on_field_of_view_enter() -> void:
	pass


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


func get_damage() -> int:
	return base_damage


func kill() -> void:
	queue_free()

################################################################################
# Serialization
################################################################################

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

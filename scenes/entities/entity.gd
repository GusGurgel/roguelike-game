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


func _ready() -> void:
	super._ready()


func get_as_dict(_return_grid_position: bool = true) -> Dictionary:
	return {
		tile = super.get_as_dict(true),
		name = self.name
	}


## Callback called when the enters the field of view of the player
func _on_field_of_view_enter() -> void:
	pass


## Callback called when the entity exits the field of view of the player
func _on_field_of_view_exit() -> void:
	pass


## Callback called when the game turn is changed
func _on_turn_updated(old_turn: int, new_turn: int) -> void:
	pass

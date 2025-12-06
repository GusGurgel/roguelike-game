extends Tile
class_name Entity

@export var max_health: int = 100
@export var health: int = 100:
	set(new_health):
		if new_health > max_health:
			health = max_health
		else:
			health = new_health

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
	print("enter")


## Callback called when the entity exits the field of view of the player
func _on_field_of_view_exit() -> void:
	print("exit")

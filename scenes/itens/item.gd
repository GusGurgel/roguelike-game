extends Tile
class_name Item

@export var usable: bool = false
@export var equippable: bool = false
@export var equipped: bool = false
@export var type: String = "default"
@export var id: int

func _ready():
	super._ready()
	is_transparent = true
	has_collision = false


func use() -> void:
	print("Using %s..." % tile_name)
	queue_free()


func equip() -> void:
	print("Equipping %s..." % tile_name)


func unequip() -> void:
	print("Unequipping %s..." % tile_name)

extends Tile
class_name Item

@export var usable: bool = false
@export var equippable: bool = false
@export var equipped: bool = false
@export var type: String = "default"
@export var description: String = "default"

signal on_unequip

var layer: Layer


func _init(_layer: Layer):
	layer = _layer


func _ready():
	super._ready()
	is_transparent = true
	has_collision = false


func use() -> void:
	print("Using %s..." % tile_name)
	queue_free()


func equip() -> void:
	equipped = true


func unequip() -> void:
	equipped = false
	on_unequip.emit()


func drop() -> bool:
	grid_position = Globals.game.player.grid_position
	var item_was_drop = Globals.game.layers.get_current_layer().items.add_item(self)

	return item_was_drop

################################################################################
# Serialization
################################################################################

func load(data: Dictionary) -> void:
	super.load(data)
	Utils.copy_from_dict_if_exists(
		self,
		data,
		[
			"usable",
			"equippable",
			"equipped",
			"description"
		]
	)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

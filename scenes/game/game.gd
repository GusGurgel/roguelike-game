extends Node
class_name Game
## Represents a parsed playable game. This contains everything the game needs to
## run.

@export var field_of_view: FieldOfView

var layer_scene = preload("res://scenes/layer.tscn")
var tile_scene = preload("res://scenes/tile.tscn")

## Just file/string JSON parsed to a Dictionary.
var raw_data: Dictionary
var player: Player
## Dictionary of game textures.
var textures: TextureList
## Dictionary of presets of tiles
var tiles_presets: TilePresetList

var turn: int = 0:
	set(new_turn):
		# Alert layer entities thats the turn has change
		# var current_layer_entities: Dictionary[String, Entity] = get_current_layer().entities
		# for entity_key in current_layer_entities:
		# 	var entity: Entity = current_layer_entities[entity_key]
		# 	if is_instance_valid(entity):
		# 		entity._on_turn_updated(turn, new_turn)
		# 	else:
		# 		# Remove invalid entity
		# 		current_layer_entities.erase(entity_key)

		game_ui.turn_value_label.text = str(new_turn)
		turn = new_turn


var game_ui: GameUI

## All layers of the game
var layers: Dictionary[String, Layer]
var current_layer: String:
	set(new_current_layer):
		var old_current_layer = current_layer
		if layers.has(new_current_layer):
			current_layer = new_current_layer
		else:
			if len(layers.keys()) > 0:
				current_layer = layers.keys()[0]
			else:
				layers["default"] = layer_scene.instantiate()
				current_layer = "default"
		if old_current_layer and layers[old_current_layer].get_parent() == self:
			remove_child(layers[old_current_layer])
		add_child(layers[current_layer])
	
@onready var tile_painter: TilePainter = $TilePainter


func _ready() -> void:
	## Set reference to game on player and field_of_view.
	player.game = self
	field_of_view.game = self

	## Add player
	add_child(player)
	game_ui.debug_ui.player = player
	player.tile_grid_position_change.connect(game_ui.debug_ui._on_player_change_grid_position)
	player.grid_position = player.grid_position


## Set a tile by a preset. [br]
## If preset == "", nothing happens.
func set_tile_by_preset(
	preset: String,
	pos: Vector2i,
	set_tile_mode: Globals.SetTileMode = Globals.SetTileMode.OVERRIDE_ALL
) -> void:
	if preset == "":
		return

	var tile: Tile

	if set_tile_mode == Globals.SetTileMode.OVERRIDE_ONLY_WITH_COLLISION:
		var current_tiles: Array[Tile] = get_tiles(pos)
		## There are no tiles with has_collision == true.
		if not Utils.any_of_array_has_propriety_with_value(current_tiles, "has_collision", true):
			return
	
	if set_tile_mode == Globals.SetTileMode.OVERRIDE_ONLY_WITH_NOT_COLLISION:
		var current_tiles: Array[Tile] = get_tiles(pos)
		## There are no tiles with has_collision == false.
		if not Utils.any_of_array_has_propriety_with_value(current_tiles, "has_collision", false):
			return
	
	tile = tile_scene.instantiate()
	tile.preset_name = preset
	tile.copy_basic_proprieties(tiles_presets.get_tile_preset(preset))
	tile.grid_position = pos
	get_current_layer().tiles.set_tile(tile)


## Return tiles from current layer on pos
func get_tiles(pos: Vector2i) -> Array[Tile]:
	return get_current_layer().get_tiles(pos)


func get_current_layer() -> Layer:
	return layers[current_layer]

	
# func get_as_dict() -> Dictionary:
# 	var result: Dictionary = self.raw_data

# 	## Get current layer tiles
# 	for layer_key in self.raw_data["layers"]:
# 		result["layers"][layer_key]["tiles"] = self.layers[layer_key].get_tiles_as_dict()
	
# 	result["player"] = player.get_as_dict()

# 	return result

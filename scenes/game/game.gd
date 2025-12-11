extends Node
class_name Game
## Represents a parsed playable game. This contains everything the game needs to
## run.

var layer_scene = preload("res://scenes/layer.tscn")
var tile_scene = preload("res://scenes/tile.tscn")

## Just file/string JSON parsed to a Dictionary.
var raw_data: Dictionary
var player: Player
## Dictionary of game textures.
var textures: Dictionary[String, AtlasTexture]
## Dictionary of presets of tiles
var tiles_presets: Dictionary[String, Tile]

var turn: int = 0:
	set(new_turn):
		# Alert layer entities
		var current_layer_entities: Dictionary[String, Entity] = get_current_layer().entities
		for entity_key in current_layer_entities:
			var entity: Entity = current_layer_entities[entity_key]
			entity._on_turn_updated(turn, new_turn)

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
	$FieldOfView.game = self

	## Add player
	add_child(player)


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
	if get_tile_preset(preset):
		Utils.print_warning("Tile preset '%s' not exists." % preset)
		preset = "default"

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
	tile.preset = preset
	tile.copy_basic_proprieties(get_tile_preset(preset))
	tile.grid_position = pos
	layers[current_layer].set_tile(tile)


## Return tiles from current layer on pos
func get_tiles(pos: Vector2i) -> Array[Tile]:
	return layers[current_layer].get_tiles(pos)


## Erase tile from the current layer. Return true if a tile was removed
func erase_tile(pos: Vector2i) -> bool:
	return layers[current_layer].erase_tile(pos)


## Return texture if exists, else returns "default" texture.
func get_texture(id_texture: String) -> AtlasTexture:
	if textures.has(id_texture):
		return textures[id_texture]
	else:
		return textures["default"]


## Return monochrome version of texture if existe, else returns "default 
## monochrome" texture
func get_texture_monochrome(id_texture: String) -> AtlasTexture:
	id_texture = "monochrome_%s" % id_texture
	if textures.has(id_texture):
		return textures[id_texture]
	else:
		return textures["monochrome_default"]


## Return tile preset, or null if not exists
func get_tile_preset(id_tile_preset) -> Tile:
	return tiles_presets.get(id_tile_preset)


func get_current_layer() -> Layer:
	return layers[current_layer]

	
func get_as_dict() -> Dictionary:
	var result: Dictionary = self.raw_data

	## Get current layer tiles
	for layer_key in self.raw_data["layers"]:
		result["layers"][layer_key]["tiles"] = self.layers[layer_key].get_tiles_as_dict()
	
	result["player"] = player.get_as_dict()

	return result

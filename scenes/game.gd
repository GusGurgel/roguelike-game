extends Node2D
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

## Tile container
var tiles_node: Node2D
## Entities container
var entities_node: Node2D


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
	

func _ready():
	add_child(player)

	var tile: Tile = tile_scene.instantiate()
	tile.texture = get_texture("tree")
	tile.grid_position = Vector2i(3, 3)
	layers[current_layer].set_tile(tile)
	layers[current_layer].erase_tile(Vector2i(2, 2))
	print(layers[current_layer].get_tile(Vector2i(2, 2)))
	print(layers[current_layer].get_tile(Vector2i(3, 3)))
	layers[current_layer].erase_tile(Vector2i(1, 1))


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


# func get_tile(pos: Vector2i) -> Tile:
# 	layers[current_layer]
	
	
## Returns a JSON string representing the current Game
## TODO
func stringify() -> String:
	return ""

extends Resource
class_name Game
## Represents a parsed playable game. This contains everything the game needs to
## run.


## Just file/string JSON parsed to a Dictionary.
var raw_data: Dictionary
var player: Player
## Dictionary of game textures.
var textures: Dictionary[String, AtlasTexture]

## All layers of the game
var layers: Dictionary[String, Layer]


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
	

## Returns a JSON string representing the current Game
## TODO
func stringify() -> String:
	return ""

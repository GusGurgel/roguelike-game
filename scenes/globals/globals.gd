extends Node
## Globals of the project

## Size of tileset in px
var tileset_size: Vector2i = Vector2i(784, 352)

## Size of tiles in px
var tile_size: Vector2i = Vector2i(16, 16)

## Sise of tileset in tiles
var tileset_count: Vector2i = tileset_size / tile_size

## Default texture used as a fallback on tilemap
var default_texture: Vector2i = Vector2i(21, 9)

enum SetTileMode {
	OVERRIDE_ALL,
	OVERRIDE_ONLY_WITH_COLLISION,
	OVERRIDE_ONLY_WITH_NOT_COLLISION
}

var colored_texture: CompressedTexture2D = preload("res://images/tileset_colored.png")
var monochrome_texture: CompressedTexture2D = preload("res://images/tileset_monochrome.png")

var scenes: Dictionary[String, PackedScene] = {
	"tile" = preload("res://scenes/tile.tscn")
}

var game: Game = null

var game_data: Dictionary = {}

func get_game() -> Game:
	if game == null:
		Utils.print_warning("Game is not ready!")
	return game
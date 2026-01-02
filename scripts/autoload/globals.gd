extends Node

################################################################################
# Tiles
################################################################################

var tileset_size: Vector2i = Vector2i(784, 352)
var tile_size: Vector2i = Vector2i(16, 16)
var tileset_count: Vector2i = tileset_size / tile_size
var default_texture: Vector2i = Vector2i(21, 9)

enum SetTileMode {
	OVERRIDE_ALL,
	OVERRIDE_ONLY_WITH_COLLISION,
	OVERRIDE_ONLY_WITH_NOT_COLLISION
}

################################################################################
# Enums
################################################################################

enum EntityType {
	ENTITY,
	ENEMY
}

enum EnemyMode {
	ENEMY_WANDERING,
	ENEMY_CHASING
}

enum ItemType {
	ITEM,
	HEALING_POTION,
	MELEE_WEAPON
}

################################################################################
# Preloads
################################################################################

var colored_texture: CompressedTexture2D = preload(
	"res://images/tileset_colored.png"
)
var monochrome_texture: CompressedTexture2D = preload(
	"res://images/tileset_monochrome.png"
)

var scenes: Dictionary[String, PackedScene] = {
}

################################################################################
# ReGex
################################################################################

var vector2i_string_regex: RegEx = RegEx.create_from_string(
	"^(-?\\d+),(-?\\d+)$"
)
var hex_color_regex: RegEx = RegEx.create_from_string(
	"^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$"
)

################################################################################
# Globals
################################################################################

var game: Game = null
var game_ui: GameUI = null
var game_data: Dictionary = {}

var astar_grid_region = Rect2i(Vector2i(-100, -100), Vector2i(300, 300))
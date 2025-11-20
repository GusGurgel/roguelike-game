extends Node2D
class_name LevelLoader


@onready var level_parser: GameParser = GameParser.new()


func _ready() -> void:
	level_parser.load_from_path("res://data/game1.json")

	if level_parser.has_erros():
		printerr("[Parser erros]")
		for error_message in level_parser.error_messages:
			printerr(error_message)
		return
	
	for warning_message in level_parser.warning_messages:
		print("Warning: ", warning_message)

	var layer: Layer = level_parser.data.layers[level_parser.data.layers.keys()[1]]
	for tile_key in layer.tiles:
		add_child(layer.tiles[tile_key])

	add_child(level_parser.data.player)

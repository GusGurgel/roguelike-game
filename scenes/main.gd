extends CanvasLayer

@export var game_viewport: SubViewport

@onready var gamer_parser: GameParser = GameParser.new()
@onready var game: Game


func _ready() -> void:
	gamer_parser.load_from_path("res://data/game1.json")

	if gamer_parser.has_erros():
		for error_message in gamer_parser.error_messages:
			printerr(error_message)
		return

	for warning_message in gamer_parser.warning_messages:
		Utils.print_warning("[color=#ffff00]⚠ Warning: %s[/color]" % warning_message)
	
	game = gamer_parser.data
	
	game_viewport.add_child(game)

	var rooms: Array[Rect2i] = game.tile_painter.generate_basic_dungeon(
		Rect2i(0, 0, 100, 100),
		10,
		10,
		20,
		"brick_wall",
		"brick_floor"
	)

	if len(rooms) > 0:
		game.player.grid_position = rooms[0].get_center()

	# $CanvasLayer/TextureRect.texture = game.get_texture_monochrome("brick_floor")
	var field_of_view: FieldOfView = game.get_node("FieldOfView") as FieldOfView

	if field_of_view:
		field_of_view.update_fov(game.player.grid_position)


func _unhandled_input(event: InputEvent) -> void:
	var event_key = event as InputEventKey

	if event_key and event_key.pressed and not event_key.echo and event_key.keycode == KEY_SPACE:
		game.set_tile_by_preset("brick_wall", game.player.grid_position + Vector2i.UP)

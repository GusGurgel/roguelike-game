extends CanvasLayer

@export var game_viewport: SubViewport
@export var game_ui: GameUI

@onready var gamer_parser: GameParser = GameParser.new()
@onready var game: Game


func _ready() -> void:
	gamer_parser.load_from_path("res://data/game3.json", game_ui)

	if gamer_parser.has_erros():
		for error_message in gamer_parser.error_messages:
			printerr(error_message)
		return

	for warning_message in gamer_parser.warning_messages:
		Utils.print_warning(warning_message)
	
	game = gamer_parser.data
	
	game_viewport.add_child(game)


func _unhandled_input(event: InputEvent) -> void:
	var event_key = event as InputEventKey

	if event_key and event_key.pressed and not event_key.echo and event_key.keycode == KEY_SPACE:
		game.set_tile_by_preset("brick_wall", game.player.grid_position + Vector2i.UP)


func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# save_game()
		pass


func save_game() -> void:
	var json_saver = JSONSaver.new()
	json_saver.save_json_data(game.get_as_dict(), "res://data/data_saved.json")
	if json_saver.has_erros():
		print("JSON saver errors: " + str(json_saver.error_messages))


func generate_dungeon() -> void:
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

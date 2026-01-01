extends CanvasLayer
class_name Main

@export var game_viewport: SubViewport
@export var game_ui: GameUI

@onready var game: Game

var game_data: Dictionary

func load_game_from_path(path: String, _game_ui: GameUI) -> Variant:
	var json_loader: JSONLoader = JSONLoader.new()

	json_loader.load_from_path(path)
	if json_loader.has_erros():
		json_loader.print_erros_and_warnings()
		return null
	else:
		return load_game_from_dict(json_loader.data, _game_ui)


func load_game_from_dict(dict: Dictionary, _game_ui: GameUI) -> Game:
	var _game: Game = Game.new()
	_game.game_ui = _game_ui

	Globals.game = _game
	
	_game.load(dict)
	_game.name = "Game"

	return _game


func _ready() -> void:
	game = load_game_from_path("res://data/game.json", game_ui)
	game_viewport.add_child(game)

	game.set_tile_by_preset("brick_floor", Vector2i(-10, -10))
	game.layers.switch_layer("default")

	get_tree().create_timer(5).timeout.connect(func() : 
		game.layers.switch_layer("main")
		game.player.update_fov()
	)


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

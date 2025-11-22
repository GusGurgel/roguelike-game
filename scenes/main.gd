extends Node2D


@onready var gamer_parser: GameParser = GameParser.new()
@onready var game: Game
@onready var timer: Timer = $ChangeSceneTimer


func _ready() -> void:
	gamer_parser.load_from_path("res://data/game1.json")

	if gamer_parser.has_erros():
		for error_message in gamer_parser.error_messages:
			printerr(error_message)
		return

	for warning_message in gamer_parser.warning_messages:
		print_rich("[color=#ffff00]⚠ Warning: %s[/color]" % warning_message)
	
	game = gamer_parser.data
	
	add_child(gamer_parser.data)
	timer.timeout.connect(func(): game.current_layer = "floresta")


func _unhandled_input(event: InputEvent) -> void:
	var event_key = event as InputEventKey

	if event_key and event_key.pressed and not event_key.echo and event_key.keycode == KEY_SPACE:
		print("espace")

extends Entity
class_name Player

## Max camera zoom multiplier
@export var max_camera_zoom: int = 4

@onready var camera = $Camera2D

## Reference to the game Scene
var game: Game

## Reference to the field of view Node
var field_of_view: FieldOfView


func _ready():
	super._ready()

	## Player need to be transparent
	is_transparent = true

	camera.position += texture.get_size() / 2
	camera.zoom = Vector2.ONE * 2

	if not game:
		Utils.print_warning("Player won't have a reference to the current game.")
		return

	field_of_view = game.get_node("FieldOfView")
	field_of_view.update_fov(grid_position)


func _unhandled_input(event: InputEvent) -> void:
	var event_key = event as InputEventKey

	if event_key:
		if event_key.is_pressed():
			_handle_movement(event_key)
			_handle_camera_zoom(event_key)


func _handle_camera_zoom(event_key: InputEventKey):
	if event_key.is_action("zoom_plus"):
		camera.zoom = clamp(camera.zoom + Vector2.ONE, Vector2.ONE, Vector2.ONE * max_camera_zoom)
	elif event_key.is_action("zoom_minus"):
		camera.zoom = clamp(camera.zoom - Vector2.ONE, Vector2.ONE, Vector2.ONE * max_camera_zoom)


func _handle_movement(event_key: InputEventKey):
	var move = Vector2i.ZERO
	if event_key.is_action("player_up"):
		move += Vector2i.UP
	elif event_key.is_action("player_down"):
		move += Vector2i.DOWN
	elif event_key.is_action("player_left"):
		move += Vector2i.LEFT
	elif event_key.is_action("player_right"):
		move += Vector2i.RIGHT
	elif event_key.is_action("player_northeast"):
		move += Vector2i.UP + Vector2i.RIGHT
	elif event_key.is_action("player_northwest"):
		move += Vector2i.UP + Vector2i.LEFT
	elif event_key.is_action("player_southeast"):
		move += Vector2i.DOWN + Vector2i.RIGHT
	elif event_key.is_action("player_southwest"):
		move += Vector2i.DOWN + Vector2i.LEFT

	## Check for collision and change player position
	if game:
		var tiles: Array[Tile] = game.get_tiles(grid_position + move)
		if not Utils.any_of_array_has_propriety_with_value(tiles, "has_collision", true):
			grid_position += move
			field_of_view.update_fov(grid_position)


func get_as_dict(_return_grid_position: bool = false) -> Dictionary:
	return {
		entity = super.get_as_dict(true),
	}

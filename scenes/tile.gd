extends Sprite2D
class_name Tile

static var tile_scene = preload("res://scenes/tile.tscn")


var grid_position: Vector2i = Vector2i(0, 0):
	set(new_grid_position):
		position = Utils.grid_position_to_global_position(new_grid_position)
		grid_position = new_grid_position


var is_explored: bool = false:
	set(new_is_explored):
		if new_is_explored and not visible:
			visible = true

		is_explored = new_is_explored


var is_in_view: bool = false:
	set(new_is_in_view):
		if new_is_in_view:
			is_explored = true
			visible = true
			modulate.a = 1
		else:
			if is_explored:
				modulate.a = 0.4
			else:
				visible = false

		is_in_view = new_is_in_view

var is_transparent = false
var has_collision = false

## Tile used as a base. [br][br]
##
## It takes this parameters into account: [i][b]texture, has_collision, modulate (color)[/b][/i].
var preset_key: String = ""
var preset: Tile:
	set(new_preset):
		preset = new_preset
		texture = preset.texture
		has_collision = preset.has_collision
		is_transparent = preset.is_transparent
		modulate = preset.modulate
		is_in_view = preset.is_in_view
		is_explored = preset.is_explored


func _ready():
	centered = false


func get_as_dict(return_grid_position: bool = false) -> Dictionary:
	var result: Dictionary = {}

	if self.preset_key != "":
		result = {
			preset = self.preset_key,
			is_explored = self.is_explored
		}
	else:
		result = {
			texture = self.texture,
			modulate = self.modulate,
			has_collision = self.has_collision,
			is_explored = self.is_explored,
			is_in_view = self.is_in_view,
			is_transparent = self.is_transparent
		}
	
	if return_grid_position:
		result["grid_position"] = {
			x = self.grid_position.x,
			y = self.grid_position.y
		}

	return result

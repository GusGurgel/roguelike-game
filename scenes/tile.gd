extends Sprite2D
class_name Tile


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

## Tile used as a base.
var preset: String = ""

var tile_name: String = ""


func _ready():
	centered = false
	# This triggers the modulate modification of tile.
	is_in_view = is_in_view


## Copy information from tile. [br]
## Considers follows proprieties: texture, has_collision, is_transparent, modulate.
func copy_basic_proprieties(tile: Tile) -> void:
	self.texture = tile.texture
	self.has_collision = tile.has_collision
	self.is_transparent = tile.is_transparent
	self.modulate = tile.modulate


func get_as_dict(return_grid_position: bool = false) -> Dictionary:
	var result: Dictionary = {}

	if preset != "":
		result = {
			preset = self.preset,
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

extends SerializableSprite2D
class_name Tile

signal tile_grid_position_change(old_pos: Vector2i, new_pos: Vector2i)


var grid_position: Vector2i = Vector2i(0, 0):
	set(new_grid_position):
		var old_grid_position: Vector2i = grid_position
		position = Utils.grid_position_to_global_position(new_grid_position)
		grid_position = new_grid_position
		tile_grid_position_change.emit(old_grid_position, grid_position)


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

var preset_name: String = ""
var texture_name: String = ""

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
	self.tile_name = tile.tile_name


func get_as_dict(return_grid_position: bool = false) -> Dictionary:
	var result: Dictionary = {}

	if preset_name != "":
		result = {
			preset_name = self.preset_name,
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


func load(data: Dictionary) -> void:
	super.load(data)

	var game: Game = Globals.get_game()
	var warnings: PackedStringArray = []

	if not game:
		return

	if data.has("grid_position"):
		if Utils.dictionary_has_all(data["grid_position"], ["x", "y"]):
			grid_position = Vector2i(data["grid_position"]["x"], data["grid_position"]["y"])
		else:
			grid_position = Vector2i.ZERO
			Utils.print_warning("Grid position of a tile is missing x or y.")

	if data.has("preset_name"):
		var tile_preset: Tile = game.tiles_presets.get_tile_preset(data["preset_name"])
		if tile_preset != null:
			texture = tile_preset.texture
			has_collision = tile_preset.has_collision
			is_transparent = tile_preset.is_transparent
			modulate = tile_preset.modulate
			tile_name = tile_preset.tile_name
		else:
			Utils.print_warning("Preset '%s' not exists." % data["preset_name"])
			data.erase("preset_name")
	
	# All textures that do not have a preset name need to have this properties
	# explicitly defined.
	if not data.has("preset_name"):
		warnings = ["grid_position", "texture", "tile_name"]

	if data.has("texture"):
		texture = game.textures.get_texture(data["texture"])

	if data.has("color"):
		if not Globals.hex_color_regex.search(data["color"]):
			Utils.print_warning("Invalid color hex '%s' on tile." % data["color"])
		if data.has("texture"):
			texture = game.textures.get_texture_monochrome(data["texture"])
		modulate = Color(data["color"])
	
	Utils.copy_from_dict_if_exists(
		self,
		data,
		[
			"preset_name",
			"is_transparent",
			"has_collision",
			"is_explored",
			"tile_name"
		],
		warnings
	)

func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()

	if preset_name != "":
		result = {
			preset_name = self.preset_name,
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
	
	result["grid_position"] = {
		x = self.grid_position.x,
		y = self.grid_position.y
	}

	return result

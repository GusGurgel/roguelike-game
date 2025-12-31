extends Node
## Utils functions


################################################################################
# Consts
################################################################################

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


################################################################################
# Godot
################################################################################

func _ready():
	rng.randomize()

################################################################################
# Functions
################################################################################


## Checks if a dictionary has all keys.
func dictionary_has_all(dict: Dictionary, keys: Array[String]) -> bool:
	for key in keys:
		if not dict.has(key):
			return false
	
	return true


## Return true if any element of array has propriety == value. Else, returns false.
func any_of_array_has_propriety_with_value(array: Array, propriety: String, value: Variant) -> bool:
	for element in array:
		if element and element.get(propriety) == value:
			return true
	
	return false


## Converts integer grid position to a global position.
func grid_position_to_global_position(grid_position: Vector2i) -> Vector2:
	return grid_position * Globals.tile_size


## Converts float global position to a integer grid_position.
func global_position_to_grid_position(global_position: Vector2) -> Vector2i:
	return Vector2(
		global_position.x / Globals.tile_size.x,
		global_position.y / Globals.tile_size.y
	)


## Print a rich warning message on the terminal.
func print_warning(message: String):
	print_rich("[color=#ffff00]⚠ Warning: %s[/color]" % message)


## Return if a index is a border of a Rect2i.
func is_border(rect: Rect2i, pos: Vector2i) -> bool:
	return (
		pos.x == rect.position.x
		|| pos.y == rect.position.y
		|| pos.x == rect.position.x + rect.size.x - 1
		|| pos.y == rect.position.y + rect.size.y - 1
	)


## Return a random Vector2i direction.
func get_random_direction() -> Vector2i:
	return Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))


## Serialize a Vector2i.
func vector2i_to_string(pos: Vector2i) -> String:
	return "%s,%s" % [pos.x, pos.y]


func string_to_vector2i(pos: String) -> Vector2i:
	if pos == "":
		return Vector2i.ZERO

	var regex_result: RegExMatch = Globals.vector2i_string_regex.search(pos)
	var grid_position: Vector2i = Vector2i.ZERO

	if not regex_result:
		Globals.print_warning("Invalid tilemap tile_key '%s'" % pos)
		return grid_position

	grid_position.x = regex_result.strings[1].to_int()
	grid_position.y = regex_result.strings[2].to_int()
	return grid_position


################################################################################
# Dictionary Functions
################################################################################

## Tests if dict.has(key) and str(dict[key]).to_lower == value
func dict_has_and_is_equal_lower_string(dict: Dictionary, key: String, value: String) -> bool:
	return dict.has(key) and str(dict[key]).to_lower() == value


## Updates an node using values from a dictionary, based on a list of properties.
## If the property exists in the dictionary and is in properties, it is copied.
## If it doesn't exist and is in warning, a warning is logged.
func copy_from_dict_if_exists(
		node: Node,
		dictionary: Dictionary,
		properties: PackedStringArray = [],
		warning: PackedStringArray = []
) -> void:
	for key in properties:
		if dictionary.has(key):
			if node.get(key) != null:
				node.set(key, dictionary.get(key))
			else:
				print_warning("Object %s does not have property '%s'." % [node, key])
		elif warning.has(key):
			print_warning("Tried to copy property '%s' to node '%s', but dictionary is missing it." % [key, node.name])

extends Node
## Utils functions

## Checks if a dictionary has all keys
func dictionary_has_all(dict: Dictionary, keys: Array[String]) -> bool:
	for key in keys:
		if not dict.has(key):
			return false
	
	return true


## Return true if any element of array has propriety == value. Else, returns false
func any_of_array_has_propriety_with_value(array: Array, propriety: String, value: Variant) -> bool:
	for element in array:
		if element and element.get(propriety) == value:
			return true
	
	return false


## Updates an node using values from a dictionary, based on a list of properties.
## If the property exists in the dictionary and is in properties, it is copied.
## If it doesn't exist and is in warning, a warning is logged.
func copy_from_dict_if_exists(
		node: Node,
		dictionary: Dictionary,
		properties: Array[String] = [],
		warning: Array[String] = []
) -> void:
	for key in properties:
		if dictionary.has(key):
			if node.get(key) != null:
				node.set(key, dictionary.get(key))
			else:
				print_warning("Object %s does not have property '%s'." % [node, key])
		elif warning.has(key):
			print_warning("Tried to copy property '%s' to node '%s', but dictionary is missing it." % [key, node.name])


## Converts integer grid position to a global position
func grid_position_to_global_position(grid_position: Vector2i) -> Vector2:
	return grid_position * Globals.tile_size


## Converts float global position to a integer grid_position
func global_position_to_grid_position(global_position: Vector2) -> Vector2i:
	return Vector2(
		global_position.x / Globals.tile_size.x,
		global_position.y / Globals.tile_size.y
	)


## Print a rich warning message
func print_warning(message: String):
	print_rich("[color=#ffff00]⚠ Warning: %s[/color]" % message)


## Return if a index is a border of a Rect2i
##
## [codeblock]
## is_border(Rect2i(0, 0, 10, 10), Vector2i(0, 0)) # true
## is_border(Rect2i(0, 0, 10, 10), Vector2i(1, 0)) # true
## is_border(Rect2i(1, 1, 10, 10), Vector2i(9, 9)) # true
## is_border(Rect2i(1, 1, 10, 10), Vector2i(1, 1)) # true
##
## is_border(Rect2i(0, 0, 10, 10), Vector2i(1, 1)) # false
## is_border(Rect2i(1, 1, 10, 10), Vector2i(2, 2)) # false
## is_border(Rect2i(1, 1, 10, 10), Vector2i(8, 8)) # false
## [/codeblock]
func is_border(rect: Rect2i, pos: Vector2i) -> bool:
	return (
		pos.x == rect.position.x
		|| pos.y == rect.position.y
		|| pos.x == rect.position.x + rect.size.x - 1
		|| pos.y == rect.position.y + rect.size.y - 1
	)

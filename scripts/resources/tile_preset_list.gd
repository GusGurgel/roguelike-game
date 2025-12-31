extends SerializableResource
class_name TilePresetList

var tiles_presets: Dictionary[String, Tile]


## Return tile_preset if exists, else returns default.
func get_tile_preset(tile_preset_key: String) -> Tile:
	if tiles_presets.has(tile_preset_key):
		return tiles_presets[tile_preset_key]
	else:
		return tiles_presets["default"]


func load(data: Dictionary) -> void:
	super.load(data)

	# Adds default tile preset
	tiles_presets["default"] = Globals.scenes["tile"].instantiate()
	tiles_presets["default"].texture = Globals.get_game().textures.get_texture("default")

	for tile_preset_key in data:
		var tile_preset_data: Dictionary = data[tile_preset_key]
		var tile: Tile = Globals.scenes["tile"].instantiate()
		tile_preset_data["grid_position"] = {x = 0, y = 0}
		tile.load(tile_preset_data)
		tiles_presets[tile_preset_key] = tile


func serialize() -> Dictionary:
	var result: Dictionary = {}
	return result
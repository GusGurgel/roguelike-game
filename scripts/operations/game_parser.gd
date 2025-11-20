extends Operation
class_name GameParser
## Parsers a JSON into a playable game.

var data: Game = Game.new()

var player_scene = preload("res://scenes/player.tscn")

var colored_texture: CompressedTexture2D = preload("res://images/tileset_colored.png")
var monochrome_texture: CompressedTexture2D = preload("res://images/tileset_monochrome.png")
var json_loader: JSONLoader = JSONLoader.new()

var tile_key_regex: RegEx = RegEx.create_from_string("^(\\d+),(\\d+)$")
var hex_color_regex: RegEx = RegEx.create_from_string("^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")


func load_from_path(path: String) -> void:
	# Load raw_data.
	json_loader.load_from_path(path)
	if json_loader.has_erros():
		error_messages.append_array(json_loader.error_messages)
		return
	
	data.raw_data = json_loader.data
	
	# Load textures.
	data.textures = parse_textures(data.raw_data)

	# Load tilemap.
	data.layers = parse_layers(data.raw_data)

	# Load player
	data.player = parse_player(data.raw_data)


## Parse all textures [br][br]
##
## Texture are load in two versions, monochrome and colored. To get de
## monochrome version just use:
## [codeblock]textures["monochrome_{texture name}"][/codeblock]
func parse_textures(raw_data: Dictionary) -> Dictionary[String, AtlasTexture]:
	var textures: Dictionary[String, AtlasTexture] = {}

	# Add the default texture
	var default_colored_texture: AtlasTexture = AtlasTexture.new()
	var default_monochrome_texture: AtlasTexture = AtlasTexture.new()
	default_colored_texture.atlas = colored_texture
	default_monochrome_texture.atlas = monochrome_texture
	default_colored_texture.region = Rect2(
		Globals.default_texture.x * Globals.tile_size.x,
		Globals.default_texture.y * Globals.tile_size.y,
		Globals.tile_size.x,
		Globals.tile_size.y
	)
	default_monochrome_texture.region = default_colored_texture.region
	textures["default"] = default_colored_texture
	textures["monochrome_default"] = default_monochrome_texture

	for key in raw_data.textures:
		var texture_data = raw_data.textures[key]

		if not Utils.dictionary_has_all(texture_data, ["x", "y"]):
			warning_messages.push_back("Texture '%s' without position." % key)
			continue

		## Add colored and monochrome versions
		var texture_colored: AtlasTexture = AtlasTexture.new()
		var texture_monochrome: AtlasTexture = AtlasTexture.new()

		texture_colored.atlas = colored_texture
		texture_monochrome.atlas = monochrome_texture
		texture_colored.region = Rect2(
			texture_data["x"] * Globals.tile_size.x,
			texture_data["y"] * Globals.tile_size.y,
			Globals.tile_size.x,
			Globals.tile_size.y
		)
		texture_monochrome.region = texture_colored.region

		textures[key] = texture_colored
		textures["monochrome_%s" % key] = texture_colored

	return textures


func parse_layers(raw_data: Dictionary) -> Dictionary[String, Layer]:
	var layers: Dictionary[String, Layer] = {}

	if not raw_data.has("layers"):
		warning_messages.push_back("Game without layers.")
		return layers

	for layer_key in raw_data["layers"]:
		layers[layer_key] = parse_layer(layer_key, raw_data["layers"])

	return layers


func parse_layer(layer_key: String, layers_data: Dictionary) -> Layer:
	var layer: Layer = Layer.new()
	var layer_data = layers_data[layer_key]


	if not layer_data.has("tiles"):
		warning_messages.push_back("Layer '%s' without tiles." % layer_key)
		return layer

	layer.tiles = parse_layer_tiles(layer_data["tiles"])

	return layer


func parse_layer_tiles(tiles_data: Dictionary) -> Dictionary[String, Tile]:
	var tiles: Dictionary[String, Tile] = {}

	for tile_key in tiles_data:
		var tile_data = tiles_data[tile_key]
		var tile: Tile = Tile.new()

		tile.grid_position = parse_tile_grid_position(tile_key)

		# Set tile position
		if not tile_data.has("texture"):
			warning_messages.push_back("Tile '%s' without a texture" % tile_key)
			continue
		tile.texture = data.get_texture(tile_data["texture"])

		# Set tile color
		if tile_data.has("color"):
			if not hex_color_regex.search(tile_data["color"]):
				warning_messages.push_back("Invalid color hex '%s' on tile '%s'" % [tile_data["color"], tile_key])
			tile.texture = data.get_texture_monochrome(tile_data["texture"])
			tile.modulate = Color(tile_data["color"])

		if tile_data.has("is_explored"):
			tile.is_explored = tile_data["is_explored"]

		if tile_data.has("is_in_view"):
			tile.is_in_view = tile_data["is_in_view"]

		tiles[tile_key] = tile

	return tiles


func parse_tile_grid_position(tile_key: String) -> Vector2i:
	var regex_result: RegExMatch = tile_key_regex.search(tile_key)
	var grid_position: Vector2i

	if not regex_result:
		warning_messages.push_back("Invalid tilemap tile_key '%s'" % tile_key)
		return grid_position

	grid_position.x = regex_result.strings[1].to_int()
	grid_position.y = regex_result.strings[2].to_int()
	return grid_position


func parse_player(raw_data: Dictionary) -> Player:
	var player: Player = player_scene.instantiate()

	if not raw_data.has("player"):
		warning_messages.push_back("Game without a player")
		return player

	var player_data = raw_data["player"]

	if not player_data.has("position"):
		warning_messages.push_back("Player without a position.")
		return player

	var player_position = player_data["position"]

	if not Utils.dictionary_has_all(player_position, ["x", "y"]):
		warning_messages.push_back("Player without a position.")
		return player
	
	if not player_data.has("texture"):
		warning_messages.push_back("Player without a texture.")
		return player

	player.grid_position = Vector2i(player_position["x"], player_position["y"])
	player.texture = data.get_texture(player_data["texture"])

	return player

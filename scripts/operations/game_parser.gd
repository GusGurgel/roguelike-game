extends Operation
class_name GameParser
## Parsers a JSON into a playable game.

var data: Game = preload("res://scenes/game/game.tscn").instantiate()

var player_scene = preload("res://scenes/entities/player.tscn")
var layer_scene = preload("res://scenes/layer.tscn")
var tile_scene = preload("res://scenes/tile.tscn")

# Entities scenes
var entity_scene = preload("res://scenes/entities/entity.tscn")
var enemy_scene = preload("res://scenes/entities/enemy.tscn")

# Items scenes
var item_scene = preload("res://scenes/itens/item.tscn")
var item_healing_potion_scene = preload("res://scenes/itens/healing_potion.tscn")
var item_melee_weapon_scene = preload("res://scenes/itens/melee_weapon.tscn")


var colored_texture: CompressedTexture2D = preload("res://images/tileset_colored.png")
var monochrome_texture: CompressedTexture2D = preload("res://images/tileset_monochrome.png")
var json_loader: JSONLoader = JSONLoader.new()

var tile_key_regex: RegEx = RegEx.create_from_string("^(-?\\d+),(-?\\d+)$")
var hex_color_regex: RegEx = RegEx.create_from_string("^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")


func load_from_path(path: String, game_ui: GameUI) -> void:
	# Load raw_data.
	json_loader.load_from_path(path)
	if json_loader.has_erros():
		error_messages.append_array(json_loader.error_messages)
		return
	
	data.raw_data = json_loader.data

	data.game_ui = game_ui
	
	# Load textures.
	data.textures = parse_textures(data.raw_data)

	# Load tiles_presets
	data.tiles_presets = parse_tiles_presets(data.raw_data)

	# Load player.
	data.player = parse_player(data.raw_data)

	# Load layers.
	data.layers = parse_layers(data.raw_data)

	# Load current_layer
	data.current_layer = parse_current_layer(data.raw_data)


	# Direct copies from the raw data
	Utils.copy_from_dict_if_exists(
		data,
		data.raw_data,
		["turn"],
		["turn"]
	)


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
		textures["monochrome_%s" % key] = texture_monochrome

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
	var layer: Layer = layer_scene.instantiate()
	var layer_data = layers_data[layer_key]


	if layer_data.has("tiles"):
		layer.tiles = parse_layer_tiles(layer_data["tiles"])
	
	if layer_data.has("entities"):
		layer.entities = parse_layer_entities(layer_data["entities"], layer)
	
	if layer_data.has("itens"):
		layer.itens = parse_layer_itens(layer_data["itens"])

	return layer


func parse_layer_tiles(tiles_data: Dictionary) -> Dictionary[String, Tile]:
	var tiles: Dictionary[String, Tile] = {}

	for tile_key in tiles_data:
		var tile: Tile = tile_scene.instantiate()
		var grid_position: Vector2i = parse_tile_grid_position(tile_key)
		tiles_data[tile_key]["grid_position"] = {
			x = grid_position.x,
			y = grid_position.y
		}
		parse_tile(tiles_data[tile_key], tile)
		tiles[tile_key] = tile

	return tiles


func parse_layer_entities(entities_data: Dictionary, layer: Layer) -> Dictionary[String, Entity]:
	var entities: Dictionary[String, Entity] = {}

	for entity_key in entities_data:
		var entity_data: Dictionary = entities_data[entity_key]
		var node: Node = null

		if Utils.dict_has_and_is_equal_lower_string(entity_data, "type", "enemy"):
			node = enemy_scene.instantiate()
			var node_enemy = node as Enemy

			if node_enemy:
				node_enemy.player = data.player
		else:
			node = entity_scene.instantiate()
		
		var node_entity = node as Entity

		if node_entity:
			var grid_position: Vector2i = parse_tile_grid_position(entity_key)
			if not entity_data.has("tile"):
				warning_messages.push_back("Entity without a tile information.")
				continue
			entity_data["tile"]["grid_position"] = {
				x = grid_position.x,
				y = grid_position.y
			}
			parse_entity(entity_data, node_entity)
			node_entity.layer = layer
			entities[entity_key] = node_entity

	return entities


func parse_layer_itens(itens_data: Dictionary) -> Dictionary[String, Item]:
	var itens: Dictionary[String, Item] = {}

	for item_key in itens_data:
		var item_data = itens_data[item_key]
		var node: Node = null

		if Utils.dict_has_and_is_equal_lower_string(item_data, "type", "healing_potion"):
			node = item_healing_potion_scene.instantiate()

			Utils.copy_from_dict_if_exists(
				node,
				item_data,
				[
					"health_increase"
				]
			)
		elif Utils.dict_has_and_is_equal_lower_string(item_data, "type", "melee_weapon"):
			node = item_melee_weapon_scene.instantiate()

			Utils.copy_from_dict_if_exists(
				node,
				item_data,
				[
					"damage"
				]
			)
		else:
			node = item_scene.instantiate()
		
		var node_item = node as Item

		if node_item:
			var grid_position: Vector2i = parse_tile_grid_position(item_key)
			if not item_data.has("tile"):
				warning_messages.push_back("Item without a tile information.")
				continue
			item_data["tile"]["grid_position"] = {
				x = grid_position.x,
				y = grid_position.y
			}
			parse_item(item_data, node_item)
			itens[item_key] = node_item

	return itens

func parse_item(item_data: Dictionary, item: Item) -> void:
	parse_tile(item_data["tile"], item as Tile)

	Utils.copy_from_dict_if_exists(
		item,
		item_data,
		[
			"usable",
			"equippable",
			"equipped",
			"description"
		]
	)

## Change tile object to the parsed data.
func parse_tile(tile_data: Dictionary, tile: Tile) -> void:
	if tile_data.has("grid_position"):
		if Utils.dictionary_has_all(tile_data["grid_position"], ["x", "y"]):
			tile.grid_position = Vector2i(tile_data["grid_position"]["x"], tile_data["grid_position"]["y"])
		else:
			warning_messages.push_back("Grid position of a tile is missing x or y.")

	if tile_data.has("preset"):
		if data.get_tile_preset(tile_data["preset"]):
			tile.preset = tile_data["preset"]
			tile.copy_basic_proprieties(data.get_tile_preset(tile_data["preset"]))
		else:
			warning_messages.push_back("Preset '%s' not exists." % tile_data["preset"])

	if tile_data.has("texture"):
		tile.texture = data.get_texture(tile_data["texture"])

	if not tile.texture:
		warning_messages.push_back("Tile without a texture.")
		tile.texture = data.get_texture("default")

	if tile_data.has("color"):
		if not hex_color_regex.search(tile_data["color"]):
			warning_messages.push_back("Invalid color hex '%s' on tile." % tile_data["color"])
		if tile_data.has("texture"):
			tile.texture = data.get_texture_monochrome(tile_data["texture"])
		tile.modulate = Color(tile_data["color"])

	Utils.copy_from_dict_if_exists(
		tile,
		tile_data,
		[
			"is_transparent",
			"has_collision",
			"is_explored",
			"tile_name"
		]
	)


func parse_tile_grid_position(tile_key: String) -> Vector2i:
	if tile_key == "":
		return Vector2i.ZERO

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
		warning_messages.push_back("Game without a player.")
		return player

	var player_data = raw_data["player"]

	if not player_data.has("entity"):
		warning_messages.push_back("Player without a entity information")
		return player
	
	parse_entity(player_data["entity"], player as Entity)
	player.is_in_view = true

	Utils.copy_from_dict_if_exists(
		player,
		player_data,
		["heal_per_turns"],
		["heal_per_turns"]
	)

	return player

func parse_entity(entity_data: Dictionary, entity: Entity) -> void:
	if not entity_data.has("tile"):
		error_messages.push_back("Entity without a tile information.")
		return
	
	parse_tile(entity_data["tile"], entity as Tile)

	Utils.copy_from_dict_if_exists(
		entity,
		entity_data,
		[
			"entity_name",
			"max_health",
			"health",
			"max_mana",
			"mana",
			"base_damage",
			"turns_to_move"
		]
	)


func parse_current_layer(raw_data: Dictionary):
	if not raw_data.has("current_layer"):
		warning_messages.push_back("Game without a current_layer.")
		return "default"
	
	if not raw_data["layers"].has(raw_data["current_layer"]):
		warning_messages.push_back("current_layer '%s' doesn't exist" % raw_data["current_layer"])
		return "default"

	return raw_data["current_layer"]


func parse_tiles_presets(raw_data: Dictionary) -> Dictionary[String, Tile]:
	var tiles_presets: Dictionary[String, Tile]

	## Add default tile
	tiles_presets["default"] = tile_scene.instantiate()
	tiles_presets["default"].texture = data.get_texture("default")

	if raw_data.has("tiles_presets"):
		for tile_preset_key in raw_data["tiles_presets"]:
			var tile: Tile = tile_scene.instantiate()
			var tile_preset_data: Dictionary = raw_data["tiles_presets"][tile_preset_key]
			tile_preset_data["grid_position"] = {
				x = 0,
				y = 0
			}
			parse_tile(tile_preset_data, tile)
			tiles_presets[tile_preset_key] = tile


	return tiles_presets


## Alters entity values to the parsed structure
# func parse_entity(raw_data: Dictionary, entity: Entity) -> void:
# 	entity.

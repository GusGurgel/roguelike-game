extends Operation
class_name GameParser
## Parsers a JSON into a playable game.

var data: Game = preload("res://scenes/game/game.tscn").instantiate()

var player_scene = preload("res://scenes/entities/player.tscn")
var layer_scene = preload("res://scenes/layer.tscn")

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

func _init():
	Globals.game = data


func load_from_path(path: String, game_ui: GameUI) -> void:
	# Load raw_data.
	json_loader.load_from_path(path)
	if json_loader.has_erros():
		error_messages.append_array(json_loader.error_messages)
		return
	
	load_from_dict(json_loader.data, game_ui)


func load_from_dict(dict: Dictionary, game_ui: GameUI) -> void:
	data.raw_data = dict

	data.game_ui = game_ui
	
	# Load textures.
	data.textures = TextureList.new()
	if not data.raw_data.has("textures"):
		Utils.print_warning("Game without a texture list.")
	else:
		data.textures.load(data.raw_data["textures"])

	# Load tiles_presets
	data.tiles_presets = TilePresetList.new()
	if not data.raw_data.has("tiles_presets"):
		Utils.print_warning("Game without a tile preset list.")
	else:
		data.tiles_presets.load(data.raw_data["tiles_presets"])

	# Load player.
	data.player = player_scene.instantiate()
	if not data.raw_data.has("player"):
		Utils.print_warning("Game without a player.")
	else:
		data.player.load(data.raw_data["player"])

	# Load layers.
	data.layers = parse_layers(data.raw_data)


	Utils.copy_from_dict_if_exists(
		data,
		data.raw_data,
		["current_layer", "turn"],
		["current_layer", "turn"]
	)


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
	layer.load(layer_data)

	# if layer_data.has("entities"):
	# 	layer.entities = parse_layer_entities(layer_data["entities"], layer)
	
	if layer_data.has("itens"):
		layer.itens = parse_layer_itens(layer_data["itens"])

	return layer


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
			# if not entity_data.has("tile"):
			# 	warning_messages.push_back("Entity without a tile information.")
			# 	continue
			entity_data["grid_position"] = {
				x = grid_position.x,
				y = grid_position.y
			}
			node_entity.load(entity_data)
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
	item.load(item_data["tile"])

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


func parse_tile_grid_position(tile_key: String) -> Vector2i:
	if tile_key == "":
		return Vector2i.ZERO

	var regex_result: RegExMatch = Globals.vector2i_string_regex.search(tile_key)
	var grid_position: Vector2i

	if not regex_result:
		warning_messages.push_back("Invalid tilemap tile_key '%s'" % tile_key)
		return grid_position

	grid_position.x = regex_result.strings[1].to_int()
	grid_position.y = regex_result.strings[2].to_int()
	return grid_position

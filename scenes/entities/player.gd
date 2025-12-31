extends Entity
class_name Player


## Max camera zoom multiplier
@export var max_camera_zoom: int = 4

@export var heal_per_turns: int = 1

@onready var camera = $Camera2D

## Reference to the game Scene
var game: Game

## Reference to the field of view Node
var field_of_view: FieldOfView

var item_frame_scene = preload("res://scenes/ui/item_frame.tscn")

var melee_weapon: MeleeWeapon = null

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
	update_fov.call_deferred()

	# Call set methods to trigger UI update
	set_health(health)
	set_max_health(max_health)
	set_mana(mana)
	set_max_mana(max_mana)


func _unhandled_input(event: InputEvent) -> void:
	var event_key = event as InputEventKey

	if event_key:
		if event_key.is_pressed():
			_handle_movement(event_key)
			_handle_camera_zoom(event_key)
			_handle_grab_item(event_key)
			if event_key.is_action("wait"):
				if game:
					pass_turns(1)

func _handle_grab_item(event_key: InputEventKey) -> void:
	if event_key.is_action("grab"):
		for tile in game.get_current_layer().get_tiles(grid_position):
			var tile_item: Item = tile as Item
			if tile_item:
				add_item_to_inventory(tile_item)
				return

		game.game_ui.prompt_text("No item to grab.")

				
func _handle_camera_zoom(event_key: InputEventKey) -> void:
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
	if game and move != Vector2i.ZERO:
		if game.get_current_layer().can_move_to_position(grid_position + move):
			grid_position += move
			update_fov.call_deferred()
			pass_turns(turns_to_move)

			for tile in game.get_current_layer().get_tiles(grid_position):
				var tile_item: Item = tile as Item

				if tile_item:
					game.game_ui.prompt_text(
						"[color=#fae7ac]%s[/color] (grab: g)" % tile_item.tile_name
					)

		else:
			for tile in game.get_current_layer().get_tiles(grid_position + move):
				var enemy: Enemy = tile as Enemy
				if enemy:
					pass_turns(turns_to_move)
					var is_enemy_dead: bool = enemy.get_hit(self, get_damage())
					if is_enemy_dead:
						game.game_ui.prompt_text(
							"[color=#88A8C5]%s[/color] kills [color=#d37073]%s[/color]" % [entity_name, enemy.entity_name]
						)
					else:
						game.game_ui.prompt_text(
							"[color=#88A8C5]%s[/color] hits [color=#d37073]%s[/color]. (Damage: %d; %s Life: %d)" % \
							[
								entity_name,
								enemy.entity_name,
								get_damage(),
								enemy.entity_name,
								enemy.health
							]
						)

## Update fov using player position
func update_fov() -> void:
	if field_of_view:
		field_of_view.update_fov(grid_position)


## Pass turns and heal player
func pass_turns(turns_count: int) -> void:
	game.turn += turns_count
	set_health(health + heal_per_turns * turns_count)


func get_hit(entity: Entity, damage: int) -> bool:
	self.health -= damage
	set_health(health)

	game.game_ui.prompt_text(
		"[color=#d37073]%s[/color] hits [color=#88A8C5]%s[/color]. (Damage: %d)" % \
		[
			entity.entity_name,
			entity_name,
			damage,
		]
	)

	return false

		
func set_health(new_health: int) -> void:
	health = new_health
	game.game_ui.health_progress_bar.value = health
	game.game_ui.health_label.text = "%d/%d" % [health, max_health]


func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	game.game_ui.health_progress_bar.max_value = max_health
	game.game_ui.health_label.text = "%d/%d" % [health, max_health]


func set_mana(new_mana: int) -> void:
	mana = new_mana
	game.game_ui.mana_progress_bar.value = mana
	game.game_ui.mana_label.text = "%d/%d" % [mana, max_mana]


func set_max_mana(new_max_mana: int) -> void:
	max_mana = new_max_mana
	game.game_ui.mana_progress_bar.max_value = max_mana
	game.game_ui.mana_label.text = "%d/%d" % [mana, max_mana]


func add_item_to_inventory(item: Item) -> void:
	game.get_current_layer().erase_item(item.grid_position)
	item.visible = false

	var item_frame: ItemFrame = item_frame_scene.instantiate()
	item_frame.item = item
	game.game_ui.add_item_frame(item_frame)


func get_damage() -> int:
	if melee_weapon != null:
		return melee_weapon.damage
	else:
		return base_damage


func get_as_dict(_return_grid_position: bool = false) -> Dictionary:
	return {
		entity = super.get_as_dict(true),
	}


func load(data: Dictionary) -> void:
	super.load(data)

	Utils.copy_from_dict_if_exists(
		self,
		data,
		["heal_per_turns"],
		["heal_per_turns"]
	)

	self.is_in_view = true
	self.is_explored = true

func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

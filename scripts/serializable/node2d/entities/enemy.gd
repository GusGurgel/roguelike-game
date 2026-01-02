extends Entity
class_name Enemy

var last_path: PackedVector2Array = []

var enemy_mode: Globals.EnemyMode = Globals.EnemyMode.ENEMY_WANDERING

var available_turns = 0


func _ready():
	super._ready()
	visible = is_in_view
		

func _on_field_of_view_enter() -> void:
	super._on_field_of_view_enter()
	visible = true
	enemy_mode = Globals.EnemyMode.ENEMY_CHASING


func _on_field_of_view_exit() -> void:
	super._on_field_of_view_exit()
	visible = false


func _on_turn_updated(old_turn: int, new_turn: int) -> void:
	available_turns += new_turn - old_turn

	while available_turns > turns_to_move:
		if enemy_mode == Globals.EnemyMode.ENEMY_WANDERING:
			step(self.grid_position + Utils.get_random_direction())
		elif enemy_mode == Globals.EnemyMode.ENEMY_CHASING:
			var astar_grid: AStarGrid2D = Globals.game.layers.get_current_layer().astar_grid
			var player: Player = Globals.game.player
			var path: PackedVector2Array = astar_grid.get_point_path(grid_position, player.grid_position)

			if len(path) == 2:
				Globals.game.player.get_hit(self, get_damage())
			else:
				step(Globals.game.player.grid_position)
				player.update_fov()

		available_turns -= turns_to_move


## Step 1 tile to de target position.
func step(target_position: Vector2i) -> void:
	var path: PackedVector2Array = layer.astar_grid.get_point_path(grid_position, target_position)

	if len(path) > 1 and Globals.game.layers.get_current_layer().can_move_to_position(path[1]):
		# Update entities dictionary
		layer.entities.entities.erase(Utils.vector2i_to_string(grid_position))
		layer.entities.entities[Utils.vector2i_to_string(path[1])] = self
		# Update astar_grid
		layer.astar_grid.set_point_solid(grid_position, false) # free old location
		layer.astar_grid.set_point_solid(path[1], true) # block new location
		# Update field of view of player
		Globals.game.player.update_fov()
		grid_position = path[1]


################################################################################
# Serialization
################################################################################
func load(data: Dictionary) -> void:
	super.load(data)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

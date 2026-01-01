extends Entity
class_name Enemy

var player: Player


var last_path: PackedVector2Array = []

var enemy_mode: Globals.EnemyMode

var available_turns = 0

func _ready() -> void:
	super._ready()

	enemy_mode = Globals.EnemyMode.ENEMY_WANDERING

func _on_field_of_view_enter() -> void:
	super._on_field_of_view_enter()
	enemy_mode = Globals.EnemyMode.ENEMY_CHASING
	

func _on_turn_updated(old_turn: int, new_turn: int) -> void:
	available_turns += new_turn - old_turn

	while available_turns > turns_to_move:
		if enemy_mode == Globals.EnemyMode.ENEMY_WANDERING:
			move_to(self.grid_position + Utils.get_random_direction())
		elif enemy_mode == Globals.EnemyMode.ENEMY_CHASING:
			var path: PackedVector2Array = layer.astar_grid.get_point_path(grid_position, player.grid_position)

			## If len(path) == 2 then the enemy is side by side to de player
			if len(path) == 2:
				player.get_hit(self, get_damage())
			elif len(path) > 1:
				move_to(path[1])
		
		player.update_fov()

		available_turns -= turns_to_move

func hit_player(damage: int) -> void:
	player.get_hit(self, damage)

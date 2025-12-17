extends Entity
class_name Enemy

var player: Player

func _ready() -> void:
	super._ready()


func hit_player(damage: int) -> void:
	player.get_hit(self, damage)
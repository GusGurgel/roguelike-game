extends Item

@export var health_increase: int = 0

func _ready() -> void:
	super._ready()
	equippable = false
	usable = true


func use() -> void:
	Globals.game.player.health += health_increase

extends Item
class_name HealingPotion

@export var health_increase: int = 0

func _ready() -> void:
	super._ready()
	equippable = false
	usable = true


func use() -> void:
	Globals.game.player.health += health_increase

################################################################################
# Serialization
################################################################################

func load(data: Dictionary) -> void:
	super.load(data)
	Utils.copy_from_dict_if_exists(
		self,
		data,
		[
			"health_increase"
		]
	)


func serialize() -> Dictionary:
	var result: Dictionary = super.serialize()
	return result

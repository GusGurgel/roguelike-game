extends Item
class_name MeleeWeapon

var damage: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	equippable = true
	usable = false


func equip() -> void:
	if equipped:
		return
	super.equip()
	if Globals.game.player.melee_weapon != null:
		Globals.game.player.melee_weapon.unequip()

	Globals.game.player.melee_weapon = self


func unequip() -> void:
	if not equipped:
		return
	super.unequip()
	Globals.game.player.melee_weapon = null

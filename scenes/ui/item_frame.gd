extends TextureRect
class_name ItemFrame

@export var item: Item

@export var name_label: Label
@export var use_button: Button
@export var equipe_button: Button
@export var drop_button: Button


func _ready() -> void:
	if item.usable:
		use_button.button_down.connect(_on_use_button_down)
	else:
		use_button.visible = false
	
	if item.equippable:
		equipe_button.button_down.connect(_on_equipe_button_down)
		item.on_unequip.connect(_on_unequip_item)

		if item.equipped:
			equipe_button.text = "unequip"
		else:
			equipe_button.text = "equipe"
	else:
		equipe_button.visible = false
	
	texture = item.texture
	self_modulate = item.modulate
	name_label.text = item.tile_name

	drop_button.button_down.connect(_on_drop_button_down)

	tooltip_text = item.description


func _on_use_button_down() -> void:
	item.use()
	queue_free()


func _on_equipe_button_down() -> void:
	if item.equipped:
		item.unequip()
		equipe_button.text = "equipe"
	else:
		item.equip()
		equipe_button.text = "unequip"


func _on_drop_button_down() -> void:
	if item.drop():
		queue_free()


func _on_unequip_item() -> void:
	equipe_button.text = "equipe"

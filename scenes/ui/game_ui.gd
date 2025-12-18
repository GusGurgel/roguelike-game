extends TabContainer
class_name GameUI

@export var prompt: RichTextLabel
@export var debug_ui: DebugUI
@export var inventory: FlowContainer

@export_group("Player Infos")
@export var turn_value_label: Label
@export var health_progress_bar: ProgressBar
@export var health_label: Label
@export var mana_progress_bar: ProgressBar
@export var mana_label: Label


func _ready():
	clear_prompt()


func clear_prompt() -> void:
	prompt.text = ""


func prompt_text(text: String, timestamp: bool = true) -> void:
	if timestamp:
		text = "[color=#A8A8A8][%s][/color] %s\n" % [Time.get_time_string_from_system(), text]

	prompt.text = prompt.text + text

func add_item_frame(item_frame: ItemFrame) -> void:
	inventory.add_child(item_frame)

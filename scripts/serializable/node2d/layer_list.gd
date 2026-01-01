extends SerializableNode2D
class_name LayerList

var layers: Dictionary[String, Layer]
var current_layer_key: String


## Returns current layer if exists, else returns default layer
func get_layer(layer_key: String) -> Layer:
	return layers.get(layer_key, layers["default"])


func get_current_layer() -> Layer:
	return get_layer(current_layer_key)


func switch_layer(layer_key: String) -> void:
	if current_layer_key and get_layer(current_layer_key).get_parent() == self:
		remove_child(get_layer(current_layer_key))

	if layers.has(layer_key):
		current_layer_key = layer_key
	else:
		current_layer_key = "default"
	add_child(get_layer(layer_key))


func load(data: Dictionary) -> void:
	super.load(data)

	# Add default layer.
	var layer_default = Layer.new()
	layer_default.name = "default"
	layers["default"] = layer_default


	if data.has("layers"):
		for layer_key in data["layers"]:
			var layer: Layer = Layer.new()
			var layer_data = data["layers"][layer_key]
			layer.load(layer_data)

			layers[layer_key] = layer
			layer.name = layer_key
	else:
		Utils.print_warning("Layers without layers array")

	if data.has("current_layer_key"):
		current_layer_key = data["current_layer_key"]
	else:
		current_layer_key = "default"
	
	switch_layer(current_layer_key)


func serialize() -> Dictionary:
	var result: Dictionary = {}
	return result

extends Resource
class_name Operation
## Represents a fallible operation with a array of "error_messages", and a
## array of "warning messages".[br][br]
##
## By convention, every resource that's inherit Operation has a data attribute
## as the result of the operation.

var error_messages: PackedStringArray = []
var warning_messages: PackedStringArray = []

func has_erros() -> bool:
	return len(error_messages) != 0

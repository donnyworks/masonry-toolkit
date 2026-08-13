extends Node
class_name FPSC_BooleanPropertySetterRandomized

@export var target_node : Node
@export var target_variable : StringName
@export var chance_out_of : int = 100
@export var set_default_true := true
@export var inverse_nodes : Array[Node]

func _ready():
	if randi_range(0,chance_out_of) == 0:
		target_node.set(target_variable,not set_default_true)
		for node in inverse_nodes:
			node.set(target_variable,set_default_true)
	else:
		target_node.set(target_variable,set_default_true)
		for node in inverse_nodes:
			node.set(target_variable,not set_default_true)

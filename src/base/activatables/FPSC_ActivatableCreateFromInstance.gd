extends FPSC_Activatable
class_name FPSC_InstanceActivatable

@export var instance : Node

@export var instantiation_position : Marker3D

@export var preserve_original := true

@onready var inst

func _ready():
	inst = instance.duplicate()
	if not preserve_original: instance.queue_free() # We fucking kill the original for existing

func on_enter(_body:Node3D):
	var new_inst = inst.duplicate()
	get_tree().current_scene.add_child(new_inst)
	new_inst.global_position = instantiation_position.global_position

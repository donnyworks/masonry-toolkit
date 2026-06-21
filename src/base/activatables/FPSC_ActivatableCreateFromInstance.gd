extends FPSC_Activatable
class_name FPSC_InstanceActivatable

@export var instance : Node3D

@export var instantiation_position : Marker3D

@export var preserve_original := true

@export var destroy_preexisting := false ## Destroy the one that already exists

@onready var inst

var new_inst : Node3D

func _ready():
	inst = instance.duplicate()
	if not preserve_original: instance.queue_free() # We fucking kill the original for existing

func on_enter(_body:Node3D):
	if new_inst != null and destroy_preexisting: new_inst.queue_free()
	new_inst = inst.duplicate()
	get_tree().current_scene.add_child(new_inst)
	new_inst.global_position = instantiation_position.global_position

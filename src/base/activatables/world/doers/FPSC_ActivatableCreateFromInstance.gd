extends FPSC_Activatable
class_name FPSC_InstanceActivatable

@export var instance : Node3D

@export var instantiation_position : Marker3D

@export var preserve_original := true

@export var destroy_preexisting := false ## Destroy the one that already exists

@export var maximum_amount_allowed := 1

@onready var inst

var just_spawned_node = false

var new_insts : Array[Node3D]

func FPSC_GetMPState():
	var arr = [just_spawned_node]
	just_spawned_node = false
	return arr

func FPSC_ApplyMPState(state):
	if state[0]:
		on_enter(Node3D.new())

func _ready():
	if instance == null:
		queue_free()
		return
	if instance in FPSC_MultiplayerFramework.cached_entities:
		FPSC_MultiplayerFramework.cached_entities.erase(instance)
	inst = instance.duplicate()
	if not preserve_original: instance.queue_free() # We fucking kill the original for existing

func on_enter(_body:Node3D):
	#if new_inst != null and destroy_preexisting: new_inst.queue_free()
	print(len(new_insts))
	if len(new_insts) >= maximum_amount_allowed and destroy_preexisting:
		if is_instance_valid(new_insts[0]):
			FPSC_MultiplayerFramework.cached_entities.erase(new_insts[0])
			new_insts[0].queue_free()
		new_insts.remove_at(0)
	var new_inst = inst.duplicate()
	get_tree().current_scene.add_child(new_inst)
	new_inst.name = inst.name + str(len(new_insts))
	new_inst.global_position = instantiation_position.global_position
	new_insts.append(new_inst)
	FPSC_MultiplayerFramework.cached_entities.append(new_inst)
	just_spawned_node = true

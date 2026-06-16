@tool
extends Node3D

@export var host : Node3D
@export var offset : Vector3 = Vector3(0,1,0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if host == null: return
	position = host.global_position + offset
	rotation = host.global_rotation
	scale = host.scale
	visible = host.visible
	pass

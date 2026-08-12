extends FPSC_Activatable
class_name FPSC_TeleportActivatable

@export var destination : Marker3D

@export var target : Node3D ## Optional. The thing being teleported.

func on_enter(_body:Node3D):
	if target == null:
		_body.global_position = destination.global_position
	else:
		target.global_position = destination.global_position

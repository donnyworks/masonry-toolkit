extends FPSC_Activatable
class_name FPSC_TeleportActivatable

@export var destination : Marker3D

func on_enter(_body:Node3D):
	_body.global_position = destination.global_position

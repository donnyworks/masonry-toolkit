extends FPSC_Activatable
class_name FPSC_UnfreezeActivatable

@export var prop : RigidBody3D 

func on_enter(_body:Node3D):
	prop.freeze = false

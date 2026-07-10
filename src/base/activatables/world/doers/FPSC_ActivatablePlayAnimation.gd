extends FPSC_Activatable
class_name FPSC_AnimationActivatable

@export var player : AnimationPlayer

@export var animation : String

func on_enter(_body:Node3D):
	player.play(animation)

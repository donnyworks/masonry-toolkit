extends FPSC_Trigger
class_name FPSC_TriggerToggleCollision

@export var target : CSGShape3D

@export var ToggleBackOnExit := false ## Toggle back to pre-toggle state when you leave the trigger

@export var ToggleVisibility := false ## Should it toggle visibility too?

func on_enter(_body:Node3D):
	print(_body.get_class())
	target.use_collision = not target.use_collision
	if ToggleVisibility: target.visible = not target.visible

func on_exit(_body:Node3D):
	if ToggleBackOnExit:
		target.use_collision = not target.use_collision
		if ToggleVisibility: target.visible = not target.visible

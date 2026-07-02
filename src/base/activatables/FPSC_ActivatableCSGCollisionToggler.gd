extends FPSC_Activatable
class_name FPSC_CSGShapeCollisionActivatable

@export var shape : CSGShape3D
@export var new_state : bool
@export var stick := false
var old_state : bool
func on_enter(_body:Node3D):
	old_state = shape.use_collision
	shape.use_collision = new_state

func on_exit(_body:Node3D):
	if not stick:
		shape.use_collision = old_state

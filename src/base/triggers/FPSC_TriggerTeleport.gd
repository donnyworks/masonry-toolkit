extends FPSC_Trigger
class_name FPSC_TriggerTeleport
### A trigger that teleports any entering bodies to a specified destination Marker3D

@export var destination : Marker3D ## The destination you want the target entit(ies/y) to end up at.
@export var modify_position : bool = false ## Do we want to reorient the body's position relative to ourselves?
@export var modify_rotation : bool = false ## Do we want to reorient the body relative to the destination?

func on_enter(body:Node3D):
	if not modify_position:
		body.position = destination.position
	else:
		body.position = (body.global_position - global_position) + destination.global_position
	if modify_rotation:
		body.rotation = (body.global_rotation - global_rotation) + destination.global_rotation

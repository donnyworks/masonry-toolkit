extends FPSC_Activatable
class_name FPSC_ImpulseDamageActivatable

@export var damage_delt : float = 0.0

@export var kill_rigidibodies := false

func on_enter(_body:Node3D):
	if "health" in _body:
		_body.health -= damage_delt
	if kill_rigidibodies and _body is RigidBody3D:
		_body.queue_free()

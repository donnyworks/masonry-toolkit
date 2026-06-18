extends FPSC_Activatable
class_name FPSC_ImpulseDamageActivatable

@export var damage_delt : float = 0.0

func on_enter(_body:Node3D):
	if "health" in _body:
		_body.health -= damage_delt

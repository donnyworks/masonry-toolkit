extends FPSC_CaseCondition
class_name FPSC_BodyNameCaseCondition

@export var ideal_name : String

@export var inverse := false

func evaluate(collider:Node3D):
	if collider.name != ideal_name:
		return inverse
	else:
		return not inverse

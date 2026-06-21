extends FPSC_CaseCondition
class_name FPSC_BodyNameCaseCondition

@export var ideal_name : String

func evaluate(collider:Node3D):
	if collider.name != ideal_name:
		return false
	else:
		return true

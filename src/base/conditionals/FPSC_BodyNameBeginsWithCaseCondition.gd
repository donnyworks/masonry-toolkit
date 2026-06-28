extends FPSC_CaseCondition
class_name FPSC_BodyNameBeginsWithCaseCondition

@export var ideal_name_beginning : String

func evaluate(collider:Node3D):
	if not collider.name.begins_with(ideal_name_beginning):
		return false
	else:
		return true

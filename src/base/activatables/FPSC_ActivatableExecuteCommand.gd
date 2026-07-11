extends FPSC_Activatable
class_name FPSC_ExecuteCommandActivatable

@export var command : String

func on_enter(_body:Node3D):
	FPSC_LevelManager.CMDLine(command)

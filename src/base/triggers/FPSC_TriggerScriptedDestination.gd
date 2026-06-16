extends FPSC_Trigger
class_name FPSC_TriggerScriptedDestination

@export var destination : FPSC_ScriptedDestination

func on_enter(body:Node3D):
	destination.on_fire_goto()

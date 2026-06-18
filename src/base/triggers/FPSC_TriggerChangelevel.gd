extends FPSC_Trigger
class_name FPSC_TriggerChangelevel

@export var other_level : PackedScene

@export var transfer_playerstate := false

func on_enter(body:Node3D):
	if body is FPSC_Player:
		if not transfer_playerstate:
			FPSC_LevelManager.ChangeLevel(other_level.resource_path)
		else:
			OS.alert("Unimplemented transfer_playerstate mode in FPSC_TriggerChangelevel","MSTK - Reality Check Failed")
			print("Masonry Toolkit - Reality Check Failed")
			print("Fake error text:")
			print("Unimplemented transfer_playerstate mode in FPSC_TriggerChangelevel")
			print("Response:")
			print("Don't care, using generic ChangeLevel")
			FPSC_LevelManager.ChangeLevel(other_level.resource_path)

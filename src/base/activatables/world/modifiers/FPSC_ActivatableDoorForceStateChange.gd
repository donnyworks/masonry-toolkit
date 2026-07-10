extends FPSC_Activatable
class_name FPSC_DoorStateActivatable

@export var target_door : FPSC_DoorActivatable
@export_enum("Open:0","Closed:1") var target_state : int

func on_enter(_body:Node3D):
	match target_state:
		0:
			target_door.animate_door_open()
		1:
			target_door.animate_door_close()

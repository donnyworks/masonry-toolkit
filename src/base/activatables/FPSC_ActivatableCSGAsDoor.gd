extends FPSC_Activatable
class_name FPSC_DoorActivatable

@export var object_as_door : CSGShape3D

@export var time : float ## Time it takes to happen

@export_enum("Up:1","Down:2","Left:3","Right:4","Forward:5","Backward:6") var move_direction := 1

var starting_position : Vector3

var ending_position : Vector3

func _ready():
	starting_position = object_as_door.position
	var ep_vector : Vector3 = Vector3.ZERO
	match move_direction:
		1:
			ep_vector = Vector3.UP
		2:
			ep_vector = -Vector3.UP
		3:
			ep_vector = -Vector3.RIGHT
		4:
			ep_vector = Vector3.RIGHT
		5:
			ep_vector = Vector3.FORWARD
		6:
			ep_vector = -Vector3.FORWARD
	ending_position = object_as_door.position + object_as_door.get_aabb().size * ep_vector


func on_enter(_body:Node3D):
	print("Bodyiingg")
	var t1 = create_tween()
	t1.tween_property(object_as_door,"position",ending_position,time)
	pass

func on_exit(_body:Node3D):
	print("Bodiing")
	var t1 = create_tween()
	t1.tween_property(object_as_door,"position",starting_position,time)
	
	pass

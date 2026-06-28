extends FPSC_Activatable
class_name FPSC_DoorActivatable

@export var object_as_door : CSGShape3D

@export var time : float = 1.0 ## Time it takes to happen

@export_enum("Up:1","Down:2","Left:3","Right:4","Forward:5","Backward:6") var move_direction := 1

@export var stay_open : bool = false

var current_position : Vector3:
	set(v):
		object_as_door.position = v
		if current_tween != null:
			current_tween.from(v)
		current_position = v
	get():
		return object_as_door.position

var starting_position : Vector3

var ending_position : Vector3

func FPSC_GetMPState():
	return [current_position]

func FPSC_ApplyMPState(args):
	current_position = args[0]

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
	await get_tree().process_frame # Wait a frame, recalcuate to be safe
	ending_position = object_as_door.position + object_as_door.get_aabb().size * ep_vector

var bodies_entered = []

var current_tween : PropertyTweener = null

func animate_door_open():
	var t1 = create_tween()
	current_tween = t1.tween_property(object_as_door,"position",ending_position,time)

func on_enter(_body:Node3D):
	print("Bodyiingg")
	bodies_entered.append(_body)
	animate_door_open()
	pass

func animate_door_close():
	var t1 = create_tween()
	current_tween = t1.tween_property(object_as_door,"position",starting_position,time)

func on_exit(_body:Node3D):
	print("Bodiing")
	if _body in bodies_entered:
		bodies_entered.erase(_body)
	if len(bodies_entered) > 0:
		return
	if not stay_open:
		animate_door_close()
	
	pass

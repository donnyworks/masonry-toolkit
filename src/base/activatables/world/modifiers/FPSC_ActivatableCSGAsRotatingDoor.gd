extends FPSC_Activatable
class_name FPSC_RotatingDoorActivatable

@export var object_as_door : CSGShape3D

@export var time : float = 1.0 ## Time it takes to happen

@export_enum("Y+:1","Y-:2","X+:3","X-:4","Z+:5","Z-:6") var move_direction := 1

@export var stay_open : bool = false

@export var can_be_used : bool = false

var current_position : Vector3:
	set(v):
		object_as_door.rotation = v
		if is_instance_valid(current_tween):
			current_tween.from(v)
		current_position = v
	get():
		return object_as_door.rotation

var starting_position : Vector3

var ending_position : Vector3

func FPSC_GetMPState():
	return [current_position]

func FPSC_ApplyMPState(args):
	current_position = args[0]

func _ready():
	starting_position = object_as_door.rotation
	var ep_vector : Vector3 = Vector3.ZERO
	match move_direction:
		1:
			ep_vector = Vector3(0,deg_to_rad(90),0)
		2:
			ep_vector = Vector3(0,deg_to_rad(-90),0)
		3:
			ep_vector = Vector3(deg_to_rad(90),0,0)
		4:
			ep_vector = Vector3(deg_to_rad(-90),0,0)
		5:
			ep_vector = Vector3(0,0,deg_to_rad(90))
		6:
			ep_vector = Vector3(0,0,deg_to_rad(-90))
	ending_position = object_as_door.rotation + ep_vector
	await get_tree().process_frame # Wait a frame, recalcuate to be safe
	ending_position = object_as_door.rotation + ep_vector
	if can_be_used:
		var ia = FPSC_InteractivityMarker.new()
		ia.name = "IntMarker"
		ia.activatable = self
		object_as_door.add_child(ia)

var bodies_entered = []

var current_tween : PropertyTweener = null

func animate_door_open():
	var t1 = create_tween()
	t1.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	current_tween = t1.tween_property(object_as_door,"rotation",ending_position,time)

func on_enter(_body:Node3D):
	print("Bodyiingg")
	bodies_entered.append(_body)
	animate_door_open()
	pass

func animate_door_close():
	var t1 = create_tween()
	t1.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	current_tween = t1.tween_property(object_as_door,"rotation",starting_position,time)

func on_exit(_body:Node3D):
	print("Bodiing")
	if _body in bodies_entered:
		bodies_entered.erase(_body)
	bodies_entered = bodies_entered.filter(func(obj): return is_instance_valid(obj))
	print(bodies_entered)
	if len(bodies_entered) > 0:
		return
	if not stay_open:
		animate_door_close()
	
	pass

func _process(delta: float) -> void:
	bodies_entered = bodies_entered.filter(func(obj): return is_instance_valid(obj))

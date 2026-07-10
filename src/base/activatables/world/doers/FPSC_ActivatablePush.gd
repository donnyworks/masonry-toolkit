extends FPSC_Activatable
class_name FPSC_PushActivatable

var bodies_inside = []

@export var push_towards : Marker3D

@export var push_force : float = 10

func on_enter(_body:Node3D):
	bodies_inside.append(_body)
	
func on_exit(_body:Node3D):
	bodies_inside.erase(_body)

func _physics_process(delta: float) -> void:
	bodies_inside = bodies_inside.filter(func(obj): return is_instance_valid(obj))
	for i in bodies_inside:
		if i is CharacterBody3D:
			i.velocity = i.position.direction_to(push_towards.position)*push_force
		if i is RigidBody3D:
			i.linear_velocity = i.position.direction_to(push_towards.position)*push_force
			i.angular_velocity = Vector3.ONE

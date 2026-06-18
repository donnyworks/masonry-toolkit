extends FPSC_Trigger
class_name FPSC_TriggerCatapult

@export var destination : Marker3D

@export var push_force : float = 10.0

@export var minimal_threshold : float = 0.0

var bodies_inside = []

func on_enter(body:Node3D):
	if body is CharacterBody3D:
		print("Checking that ",body.velocity.length()," is above ",minimal_threshold)
		if abs(body.velocity.length()) > minimal_threshold:
			bodies_inside.append(body)
	if body is RigidBody3D:
		if abs(body.linear_velocity.length()) > minimal_threshold:
			bodies_inside.append(body)

func on_exit(_body): pass

func _process(delta: float) -> void:
	for body in bodies_inside:
		if body is CharacterBody3D:
			body.velocity = body.global_position.direction_to(destination.global_position) * push_force
			if destination.global_position.distance_to(body.global_position) < 0.25:
				bodies_inside.erase(body)
		if body is RigidBody3D:
			body.linear_velocity = body.global_position.direction_to(destination.global_position) * push_force
			body.angular_velocity = Vector3.ONE*2
			if destination.global_position.distance_to(body.global_position) < 0.25:
				bodies_inside.erase(body)
				#body.angular_velocity = Vector3.ONE

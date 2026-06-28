extends Node
class_name FPSC_Activatable

@export var delay := 0.0 ## Delay, in seconds

func on_enter(_body:Node3D): pass
	#print("Replace this with function body.")

func on_exit(_body:Node3D): pass
	#print("Replace this with function body.")

func _delay_on_enter(body):
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(body):
		on_enter(body)

func _delay_on_exit(body):
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(body):
		on_exit(body) # Setting an instantiated box on a button that spawns the box causes a crash because it deletes the original.w
	else:
		on_exit(Node3D.new())

extends FPSC_Activatable
class_name FPSC_CounterActivatable

@export var min_ct = 0
@export var max_ct = 0
@export var trigger_on_max : FPSC_Activatable

var bodies_inside = []

func _process(_delta: float) -> void:
	bodies_inside = bodies_inside.filter(func(obj): return is_instance_valid(obj))

func on_enter(body):
	bodies_inside.append(body)
	if len(bodies_inside) == max_ct:
		trigger_on_max.on_enter(body)

func on_exit(_body):
	bodies_inside.erase(_body)
	trigger_on_max.on_exit(_body)

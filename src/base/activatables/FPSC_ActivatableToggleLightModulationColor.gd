extends FPSC_Activatable
class_name FPSC_LightColorActivatable
## Changes the color of a sprite

@export var light: Light3D

@export var off_color : Color

@export var on_color : Color

var bodies_inside = []

func on_enter(_body:Node3D):
	light.light_color = on_color
	bodies_inside.append(_body)

func on_exit(_body:Node3D):
	bodies_inside.erase(_body)
	bodies_inside = bodies_inside.filter(func(obj): return is_instance_valid(obj))
	if len(bodies_inside) == 0:
		light.light_color = off_color

func _process(delta: float) -> void:
	bodies_inside = bodies_inside.filter(func(obj): return is_instance_valid(obj))

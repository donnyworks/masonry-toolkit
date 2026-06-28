extends FPSC_Activatable
class_name FPSC_SpriteColorActivatable
## Changes the color of a sprite

@export var sprite : Sprite3D

@export var off_color : Color

@export var on_color : Color

var bodies_inside = []

func on_enter(_body:Node3D):
	sprite.modulate = on_color
	bodies_inside.append(_body)

func on_exit(_body:Node3D):
	bodies_inside.erase(_body)
	if len(bodies_inside) == 0:
		sprite.modulate = off_color

extends FPSC_Activatable
class_name FPSC_TextureChangeActivatable

@export var sprite : Sprite3D
var texture_a : Texture
@export var texture_b : Texture
@export var switch_back_on_exit : bool = false

var bodies_inside = []

func _ready():
	texture_a = sprite.texture

func on_enter(_body:Node3D):
	sprite.texture = texture_b
	bodies_inside.append(_body)

func on_exit(_body:Node3D):
	bodies_inside.erase(_body)
	if len(bodies_inside) == 0:
		if switch_back_on_exit:
			sprite.texture = texture_a

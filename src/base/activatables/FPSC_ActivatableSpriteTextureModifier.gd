extends FPSC_Activatable
class_name FPSC_TextureChangeActivatable

@export var sprite : Sprite3D
var texture_a : Texture
@export var texture_b : Texture
@export var switch_back_on_exit : bool = false

func on_enter(_body:Node3D):
	texture_a = sprite.texture
	sprite.texture = texture_b

func on_exit(_body:Node3D):
	if switch_back_on_exit:
		sprite.texture = texture_a

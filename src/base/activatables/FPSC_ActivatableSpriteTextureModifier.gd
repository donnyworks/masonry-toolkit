extends FPSC_Activatable
class_name FPSC_TextureChangeActivatable

@export var sprite : Sprite3D
@export var texture_b : Texture

func on_enter(_body:Node3D):
	sprite.texture = texture_b

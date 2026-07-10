extends FPSC_Activatable
class_name FPSC_SoundPlayerActivatable

@export var stream_player : AudioStreamPlayer3D # Spatial sound only

func on_enter(_body:Node3D):
	stream_player.play()

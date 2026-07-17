extends FPSC_Activatable
class_name FPSC_SoundPlayerActivatable

@export var stream_player : AudioStreamPlayer3D # Spatial sound only

@export var do_on_enter := true
@export var do_on_exit := false

func on_enter(_body:Node3D):
	if do_on_enter: stream_player.play()

func on_exit(_body:Node3D):
	if do_on_exit: stream_player.play()

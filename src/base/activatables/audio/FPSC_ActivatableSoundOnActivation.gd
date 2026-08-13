extends FPSC_Activatable
class_name FPSC_SoundPlayerActivatable

@export var stream_player : AudioStreamPlayer3D # Spatial sound only

@export var do_on_enter := true
@export var do_on_exit := false
@export var stop := false

func on_enter(_body:Node3D):
	if do_on_enter:
		if not stop:
			stream_player.play()
		else:
			stream_player.stop()

func on_exit(_body:Node3D):
	if do_on_exit:
		if not stop:
			stream_player.play()
		else:
			stream_player.stop()

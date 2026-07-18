extends FPSC_Activatable
class_name FPSC_RelayActivatable

@export var activatables : Array[FPSC_Activatable]

@export var use_delay_on_enter := false

@export var use_delay_on_exit := false

@export var AwaitFrame := false ## await get_tree().process_frame

@export var FireOnExitAfterDelay := false
@export var DelayAmount := 0.0

func on_enter(_body:Node3D):
	if AwaitFrame:
		await get_tree().process_frame
	@warning_ignore("standalone_ternary")
	for a in activatables:
		if not use_delay_on_enter:
			a.on_enter(_body)
		else:
			a._delay_on_enter(_body)
		if FireOnExitAfterDelay:
			fireonexit(_body,a)

func fireonexit(_body,a):
	await get_tree().create_timer(DelayAmount).timeout
	if use_delay_on_exit:
		a._delay_on_exit(_body)
	else:
		a.on_exit(_body)

func on_exit(_body:Node3D):
	@warning_ignore("standalone_ternary")
	for a in activatables:
		if not use_delay_on_exit:
			a.on_exit(_body)
		else:
			a._delay_on_exit(_body)

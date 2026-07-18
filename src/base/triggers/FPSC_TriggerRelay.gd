extends FPSC_Trigger
class_name FPSC_TriggerRelay

@export var activated : Array[FPSC_Activatable]

@export var UseActivationDelay := false ## Use the delay set up in the activator

@export var UseActivationDelayOnExit := false ## Use the delay set up in the activator when leaving the trigger

@export var FireOnExitAfterDelay := false
@export var DelayAmount := 0.0

func on_enter(body:Node3D):
	for trigger in activated:
		if trigger == null: continue
		if not UseActivationDelay:
			trigger.on_enter(body)
		else:
			trigger._delay_on_enter(body)
		if FireOnExitAfterDelay:
			await get_tree().create_timer(DelayAmount).timeout
			if UseActivationDelayOnExit:
				trigger._delay_on_exit(body)
			else:
				trigger.on_exit(body)

func on_exit(body:Node3D):
	for trigger in activated:
		if trigger == null: continue
		if not UseActivationDelayOnExit:
			trigger.on_exit(body)
		else:
			trigger._delay_on_exit(body)

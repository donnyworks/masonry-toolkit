extends FPSC_Trigger
class_name FPSC_TriggerRelay

@export var activated : Array[FPSC_Activatable]

@export var UseActivationDelay := false ## Use the delay set up in the activator

@export var UseActivationDelayOnExit := false ## Use the delay set up in the activator when leaving the trigger

func on_enter(body:Node3D):
	for trigger in activated:
		if not UseActivationDelay:
			trigger.on_enter(body)
		else:
			trigger._delay_on_enter(body)

func on_exit(body:Node3D):
	for trigger in activated:
		if not UseActivationDelayOnExit:
			trigger.on_exit(body)
		else:
			trigger._delay_on_exit(body)

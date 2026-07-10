extends FPSC_Activatable
class_name FPSC_TriggerStatusActivatable
## Turns on/off a trigger when activated.

@export var trigger : FPSC_Trigger

@export var inverted := false ## On when not activated instead of on when activated

@export var one_way := false

var pretrigger_state : FPSC_Trigger.ConnectFlags

func _ready():
	pretrigger_state = trigger.interact_with
	if not inverted:
		trigger.interact_with = 0
	else:
		trigger.interact_with = pretrigger_state

func on_enter(_body:Node3D):
	if inverted:
		trigger.interact_with = 0
	else:
		trigger.interact_with = pretrigger_state

func on_exit(_body:Node3D):
	if one_way:
		trigger.interact_with = pretrigger_state
		for body in trigger.get_overlapping_bodies():
			trigger.on_exit(body)
		trigger.interact_with = 0
		return
	if not inverted:
		trigger.interact_with = 0
	else:
		trigger.interact_with = pretrigger_state

extends FPSC_Activatable
class_name FPSC_CounterActivatable

@export var min_ct = 0
@export var value = 0
@export var max_ct = 0
@export var trigger_on_max : FPSC_Activatable

func on_enter(body):
	value += 1
	if value < min_ct: # HOW???
		value = min_ct
	if value > max_ct:
		value = max_ct
	if value == max_ct:
		trigger_on_max.on_enter(body)

func on_exit(_body):
	value -= 1
	if value < min_ct:
		value = min_ct
	if value == min_ct:
		trigger_on_max.on_exit(_body)

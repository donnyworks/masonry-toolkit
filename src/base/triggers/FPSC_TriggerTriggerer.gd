extends FPSC_Trigger
class_name FPSC_TriggerTriggerer

@export var triggers : Array[FPSC_Trigger]

@export var UseTriggerFilters := false ## Use the filtering (FPSC_CaseCondition, Interact With values) on the triggers fired as well as the filtering on this one.

func on_enter(body:Node3D):
	for trigger in triggers:
		if not UseTriggerFilters:
			trigger.on_enter(body)
		else:
			trigger._on_enter(body)

func on_exit(body:Node3D):
	for trigger in triggers:
		if not UseTriggerFilters:
			trigger.on_exit(body)
		else:
			trigger._on_exit(body)

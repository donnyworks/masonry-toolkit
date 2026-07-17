extends Node
class_name FPSC_SettingPropertyController
### A class specifically designated to make it so that game settings can control in-game things without having to have custom script classes for everything

@export var LM_property : String ## The property taken from LevelManager
@export var TARGET_property : String ## The property the value is applied to

@export var show_if_enabled : Node3D
@export var hide_if_enabled : Node3D

func _process(delta: float) -> void:
	if show_if_enabled != null: show_if_enabled.set(TARGET_property,FPSC_LevelManager.get(LM_property))
	if hide_if_enabled != null: hide_if_enabled.set(TARGET_property,not FPSC_LevelManager.get(LM_property))

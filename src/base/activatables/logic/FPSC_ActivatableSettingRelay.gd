extends FPSC_Activatable
class_name FPSC_SettingRelayActivatable

@export var activatables : Array[FPSC_Activatable]

@export var setting : String ## The property taken from FPSC_LevelManager to determine if this relay is allowed to trigger
@export var invert : bool ## Should we invert the value of the property?

@export var use_delay_on_enter := false

@export var use_delay_on_exit := false

func on_enter(_body:Node3D):
	if FPSC_LevelManager.get(setting) or (false if not invert else not FPSC_LevelManager.get(setting)):
		@warning_ignore("standalone_ternary")
		for a in activatables:
			if not use_delay_on_enter:
				a.on_enter(_body)
			else:
				a._delay_on_enter(_body)

func on_exit(_body:Node3D):
	if FPSC_LevelManager.get(setting) or (false if not invert else not FPSC_LevelManager.get(setting)):
		@warning_ignore("standalone_ternary")
		for a in activatables:
			if not use_delay_on_exit:
				a.on_exit(_body)
			else:
				a._delay_on_exit(_body)

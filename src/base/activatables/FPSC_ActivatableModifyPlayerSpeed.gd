extends FPSC_Activatable
class_name FPSC_PlayerPropertiesActivatable

@export var IgnoreEntryClass : bool = false

@export_group("Speed Controls")
@export var new_speed : float = 5.0
@export var modify_jump_velocity : bool = false

@export_group("Fade Controls")
@export var activate_fade : bool = false
@export var fade_type : FPSC_Player.FadeTypes
@export var fade_color : Color
@export var fade_duration : float

func on_enter(_body:Node3D):
	if _body is FPSC_Player or IgnoreEntryClass:
		if modify_jump_velocity:
			var speed_fraction = new_speed/FPSC_Player.base_speed
			FPSC_Player.sessionPlayer.JUMP_VELOCITY = speed_fraction*FPSC_Player.base_jv
		FPSC_Player.sessionPlayer.SPEED = new_speed
		if activate_fade:
			FPSC_Player.sessionPlayer.FPSC_ExecuteFade(fade_color,fade_type,fade_duration)

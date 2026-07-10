extends FPSC_Activatable
class_name FPSC_PlayerPropertiesActivatable

@export var IgnoreEntryClass : bool = false

@export_group("Speed Controls")
@export var new_speed : float = 5.0
@export var modify_jump_velocity : bool = false
@export var modify_extraneous_speed : bool = true

@export_group("Fade Controls")
@export var activate_fade : bool = false
@export var fade_type : FPSC_Player.FadeTypes
@export var fade_color : Color
@export var fade_duration : float

@export_group("Chapter Title Controls")
@export var chapter_title : String ## Leave blank for "don't use"
@export var chapter_subtext : String
@export var color_of_title : Color
@export var title_duration : float = 2.0

func on_enter(_body:Node3D):
	if _body is FPSC_Player or IgnoreEntryClass:
		var speed_fraction = new_speed/FPSC_Player.base_speed
		if modify_jump_velocity:
			FPSC_Player.sessionPlayer.JUMP_VELOCITY = speed_fraction*FPSC_Player.base_jv
		if modify_extraneous_speed:
			FPSC_Player.sessionPlayer.SPEED_CROUCH = FPSC_Player.base_speed_crouch*speed_fraction
			FPSC_Player.sessionPlayer.SPEED_SPRINT = FPSC_Player.base_speed_sprint*speed_fraction
		FPSC_Player.sessionPlayer.SPEED = new_speed
		if activate_fade:
			FPSC_Player.sessionPlayer.FPSC_ExecuteFade(fade_color,fade_type,fade_duration)
		if chapter_title != "":
			FPSC_Player.sessionPlayer.FPSC_ShowChapterTitle(chapter_title,color_of_title,title_duration,chapter_subtext)

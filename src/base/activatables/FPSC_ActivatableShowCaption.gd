extends FPSC_Activatable
class_name FPSC_CaptionPlayerActivatable

@export var localized_caption : String # The caption to go along with this voiceline.
@export var execute_once := false
@export var execute_after_playing : FPSC_Activatable
@export var override_preexisting_vo := false
@export var caption_lasting_time := 1.0

var executed := false

func on_enter(_body:Node3D):
	if execute_once:
		if executed:
			return
		executed = true
	FPSC_CaptionSystem.FPSC_AddCaptionLine(FPSC_LocalizationSystem.FPSC_GetLocalString(localized_caption),caption_lasting_time)
	await get_tree().create_timer(caption_lasting_time).timeout
	if execute_after_playing != null:
		execute_after_playing.on_enter(_body)

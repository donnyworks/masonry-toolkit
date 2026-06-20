extends FPSC_Activatable
class_name FPSC_VoicelineActivatable

@export var voiceline_player : Node ## AudioStreamPlayer of some kind
@export var character_voiceline : AudioStream # Could be an MP3, a WAV, or any other stream.
@export var localized_caption : String # The caption to go along with this voiceline.

func on_enter(_body:Node3D):
	if voiceline_player.playing:
		await get_tree().create_timer(voiceline_player.stream.get_length() - voiceline_player.get_playback_position()).timeout
	voiceline_player.stream = character_voiceline
	voiceline_player.play()
	FPSC_CaptionSystem.FPSC_AddCaptionLine(FPSC_LocalizationSystem.FPSC_GetLocalString(localized_caption),character_voiceline.get_length())

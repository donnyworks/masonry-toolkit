extends FPSC_Activatable
class_name FPSC_MultiVoicelineActivatable

@export var voiceline_player : Node ## AudioStreamPlayer of some kind
@export var character_voicelines : Array[AudioStream] ## Could be an MP3, a WAV, or any other stream.
@export var delay_between_voicelines : float = 0.5
@export var localized_caption_prefix : String ## The caption category to go along with these voiceline.

func on_enter(_body:Node3D):
	if voiceline_player.playing:
		await get_tree().create_timer(voiceline_player.stream.get_length() - voiceline_player.get_playback_position()).timeout
	for character_voiceline_id in range(len(character_voicelines)):
		var character_voiceline = character_voicelines[character_voiceline_id]
		var specialized_string = ("0" + str(character_voiceline_id+1) if (character_voiceline_id+1) < 10 else str(character_voiceline_id+1))
		var localized_caption = localized_caption_prefix + specialized_string
		voiceline_player.stream = character_voiceline
		voiceline_player.play()
		FPSC_CaptionSystem.FPSC_AddCaptionLine(FPSC_LocalizationSystem.FPSC_GetLocalString(localized_caption),character_voiceline.get_length() + delay_between_voicelines*2)
		await get_tree().create_timer(character_voiceline.get_length() + delay_between_voicelines).timeout

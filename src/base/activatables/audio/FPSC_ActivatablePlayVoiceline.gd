extends FPSC_Activatable
class_name FPSC_VoicelineActivatable

@export var voiceline_player : Node ## AudioStreamPlayer of some kind
@export var character_voiceline : AudioStream # Could be an MP3, a WAV, or any other stream.
@export var localized_caption : String # The caption to go along with this voiceline.
@export var execute_once := false
@export var execute_after_playing : FPSC_Activatable
@export var override_preexisting_vo := false

var executed := false

func _ready():
	if character_voiceline.resource_path.contains("res://sound/vo"): # Ripe for localization!
		if FileAccess.file_exists(character_voiceline.resource_path.replace("res://sound/vo","res://sound/vo_" + FPSC_LocalizationSystem.language)):
			character_voiceline = load(character_voiceline.resource_path.replace("res://sound/vo","res://sound/vo_" + FPSC_LocalizationSystem.language))

func on_enter(_body:Node3D):
	if execute_once:
		if executed:
			return
		executed = true
	if voiceline_player.playing and not override_preexisting_vo:
		await get_tree().create_timer(voiceline_player.stream.get_length() - voiceline_player.get_playback_position()).timeout
	voiceline_player.stream = character_voiceline
	voiceline_player.play()
	FPSC_CaptionSystem.FPSC_AddCaptionLine(FPSC_LocalizationSystem.FPSC_GetLocalString(localized_caption),character_voiceline.get_length())
	await voiceline_player.finished
	if execute_after_playing != null:
		execute_after_playing.on_enter(_body)

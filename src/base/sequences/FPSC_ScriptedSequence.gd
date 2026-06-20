extends Node
class_name FPSC_ScriptedSequence

## A scripted sequence is a series of events that can occur after a FPSC_ScriptedDestination and before the next one.

@export var character_voiceline : AudioStream # Could be an MP3, a WAV, or any other stream.
@export var localized_caption : String # The caption to go along with this voiceline.
@export var gesture_animations : Array[String] # An array of animation names.

func ExecScriptedSequence(actor:FPSC_BaseMotionAI):
	if not FPSC_BuildFeatures.BuildFeatures.FEATURE_SCRIPTEDSEQUENCE:
		print("[FPSC_ScriptedSequence] Scripted sequences have been disabled in the build configuration!")
		return
	if character_voiceline != null:
		actor.PlayVoiceline(character_voiceline)
		FPSC_CaptionSystem.FPSC_AddCaptionLine(FPSC_LocalizationSystem.FPSC_GetLocalString(localized_caption),character_voiceline.get_length())
	for gesture in gesture_animations:
		actor.PlayAnimation(gesture)
		await actor.OnAnimationFinished

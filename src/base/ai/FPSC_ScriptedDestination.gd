extends Marker3D
class_name FPSC_ScriptedDestination

## A class representing a point an AI (played by FPSC_BaseMotionAI) is to walk to
## Funnily enough, this is NOT an Activatable, (by neccessity of inhereting Marker3D to have a good positional gauge)
## It's actually meant to be triggered by an FPSC_TriggerScriptedDestination (which itself is a hotwired FPSC_Trigger, can be triggered by FPSC_TriggerTriggerer)
@export var target : FPSC_BaseMotionAI
@export var cutscene_data : FPSC_ScriptedSequence
@export var next_destination : FPSC_ScriptedDestination
@export_group("Animations")
@export var walking_animation := "walk"
@export var pre_walking_animation := "" ## If any of these three values are blank, they won't do anything.
@export var post_walking_animation := ""
@export var post_walking_idle_animation := ""

func on_fire_goto():
	print("Scripted sequence start %s - animation order [%s %s %s %s]" % [name, pre_walking_animation,walking_animation,post_walking_animation,post_walking_idle_animation])
	assert(target != null,"Target is null in scripted sequence!")
	if pre_walking_animation != "":
		target.PlayAnimation(pre_walking_animation)
		await target.OnAnimationFinished
	print("Pre walking animation done!")
	target.PlayAnimation(walking_animation)
	target.SetDestination(position)
	print("And we're off!")
	await target.OnPathingFinished
	if post_walking_animation != "":
		target.PlayAnimation(post_walking_animation)
		await target.OnAnimationFinished
	if cutscene_data != null:
		cutscene_data.ExecScriptedSequence(target)
	if next_destination == null:
		target.PlayAnimation(post_walking_idle_animation)
		await target.OnAnimationFinished
	else:
		next_destination.on_fire_goto()

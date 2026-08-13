extends Area3D
class_name FPSC_Trigger

@export var logicalCondition : FPSC_CaseCondition ## Optional logical condition block.

@export var delay : float = 0.0 ## Delay, in seconds

@export var trigger_once : bool = false

var canBeTriggered : bool = true

@export_flags("Player:1","World:2","Physics Props:4","NPCs:8","Everything:16") var interact_with : int = 5

@export var visibility_dependant : bool = false ## Makes the trigger require that it be visible to work.

func _ready():
	connect("body_entered",_on_enter)
	connect("body_exited",_on_exit)

func _flagsEval(body:Node3D): # Evaluate interact_with flags
	if visibility_dependant and not visible:
		return false
	if interact_with & 1 and body is FPSC_Player:
		#print("This is the player crossing the border")
		return true
	if interact_with & 2 and (body is StaticBody3D or body is CSGShape3D):
		#print("Bringing the world and the coastal border")
		return true
	if interact_with & 4 and body is RigidBody3D:
		#print("Letters for the physics")
		return true
	if interact_with & 8 and (body is CharacterBody3D and not body is FPSC_Player):
		#print("Letters for the poor")
		return true
	if interact_with & 16:
		#print("The shop in the world or the girl next door")
		return true
	return false

@warning_ignore("unused_parameter")
func on_enter(body:Node3D):
	pass # Inheretence, baby!

@warning_ignore("unused_parameter")
func on_exit(body:Node3D):
	pass # Inheretence, baby!

func _on_enter(body:Node3D):
	var shouldRun = true
	if logicalCondition != null:
		shouldRun = logicalCondition.evaluate(body)
	# Flag evaluation
	if shouldRun and canBeTriggered:
		if _flagsEval(body):
			await get_tree().create_timer(delay).timeout
			on_enter(body)
			if canBeTriggered and trigger_once:
				canBeTriggered = false

func _on_exit(body:Node3D):
	var shouldRun = true
	if logicalCondition != null:
		shouldRun = logicalCondition.evaluate(body)
	# Flag evaluation
	if shouldRun:
		if _flagsEval(body): on_exit(body)
		if not canBeTriggered: queue_free() # No point in keeping around

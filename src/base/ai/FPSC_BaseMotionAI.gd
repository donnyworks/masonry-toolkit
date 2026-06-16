extends CharacterBody3D
class_name FPSC_BaseMotionAI

@export var animation_player : AnimationPlayer
@export var agent : NavigationAgent3D
@export var voiceline_player : AudioStreamPlayer3D
@export var SPEED := 5.0

signal OnAnimationFinished()
signal OnPathingFinished()

func _ready():
	assert(agent != null,"Whoops! You have to put the agent in your computer!")
	agent.target_desired_distance = 1.5
	animation_player.connect("animation_finished",AnimationComplete)
	agent.connect("navigation_finished",NavComplete)

func NavComplete():
	StartPathing = false
	print("[FPSC_BaseMotionAI] Navigation complete.")
	OnPathingFinished.emit()

func AnimationComplete(_a_name):
	OnAnimationFinished.emit()

func PlayAnimation(animation_name:String):
	print("[FPSC_BaseMotionAI] Asked to play animation " + animation_name)
	if animation_name == "":
		OnAnimationFinished.emit()
		return
	animation_player.play(animation_name)

var StartPathing = false

func SetDestination(pos:Vector3):
	assert(agent != null,"Whoops! You have to put the agent in your computer!")
	agent.target_position = pos
	StartPathing = true
	print("[FPSC_BaseMotionAI] Begin pathing")

func ModifyHeadAngle(delta:float,angle:float):
	pass

func PlayVoiceline(voiceline : AudioStream):
	if voiceline_player != null:
		voiceline_player.stream = voiceline
		voiceline_player.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not StartPathing:
		if velocity.z > 0.1 or velocity.z < 0.1: # Slow the NPC down
			velocity.x = move_toward(velocity.x,0,delta*10.0)
			velocity.z = move_toward(velocity.z,0,delta*10.0)
		move_and_slide()
		return
	assert(agent != null,"Whoops! You have to put the agent in your computer!")
	look_at(agent.get_next_path_position())
	rotation_degrees.y += 180 # Why do we have to wear these ridiculous variables?
	ModifyHeadAngle(delta,rotation_degrees.x)
	rotation_degrees.x = 0
	rotation_degrees.z = 0
	var direction := (transform.basis * Vector3(0, 0, 1)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

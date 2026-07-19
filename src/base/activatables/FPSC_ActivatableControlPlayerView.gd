extends FPSC_Activatable
class_name FPSC_ViewControlActivatable

@export var target_camera : Camera3D

@export var replicate_angles := false

@export var replicate_position := false

@export var replicate_fov := true

@export var on_start := false

var running = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewControllers.append(self)
	connect("tree_exiting",exit_maneuver)
	if on_start:
		running = true
	pass # Replace with function body.

func on_enter(_body:Node3D):
	running = not running

func exit_maneuver():
	viewControllers.erase(self)

static var viewControllers = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_inside_tree(): return
	if FPSC_Player.sessionPlayer == null:
		target_camera.current = false
		return
	if running:
		var empty = true
		for contr in viewControllers:
			if contr == self: continue
			if contr.target_camera.current:
				empty = false
		if not empty: # Even if we're turned on, we shouldn't rain on someone else's [.running]...
			return
		target_camera.current = true
		FPSC_Player.sessionPlayer.get_node("Camera3D").current = false
		if replicate_position: target_camera.position = FPSC_Player.sessionPlayer.position + FPSC_Player.sessionPlayer.get_node("Camera3D").position # if you give the target camera a parent with a moved origin, this could be useful
		if replicate_angles: target_camera.rotation = FPSC_Player.sessionPlayer.rotation + FPSC_Player.sessionPlayer.get_node("Camera3D").rotation
		if replicate_fov: target_camera.fov = FPSC_Player.sessionPlayer.get_node("Camera3D").fov
	else:
		target_camera.current = false
		var empty = true
		for contr in viewControllers:
			if not contr.is_inside_tree(): continue
			if contr.target_camera.current:
				empty = false
		if empty:
			FPSC_Player.sessionPlayer.get_node("Camera3D").current = true

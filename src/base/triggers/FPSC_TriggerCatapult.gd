@tool
extends FPSC_Trigger
class_name FPSC_TriggerCatapult

@export var destination : Marker3D

@export var push_force : float = 10.0

@export var minimal_threshold : float = 0.0

@export_tool_button("Toggle Simulation", "Callable")
var my_button = _on_button_clicked

@export_tool_button("Toggle FPS Controls", "Callable")
var toggle_fps = _togglefps

var simulator = false

var simulatedBody = CharacterBody3D.new()

var fps = true

var spos = Vector3.ZERO
var srot = Vector3.ZERO

func _togglefps():
	fps = not fps

func _ready():
	if Engine.is_editor_hint():
		var mesh = preload("res://instances/player_scalemarker.tscn").instantiate()
		simulatedBody.add_child(mesh)
		var cs = CollisionShape3D.new()
		cs.shape = CapsuleShape3D.new()
		simulatedBody.add_child(cs)
		var camstandin = Node3D.new()
		camstandin.name = "camstandin"
		camstandin.position.y = 0.7
		simulatedBody.add_child(camstandin)
		var ts = GDScript.new()
		ts.source_code = """@tool
extends CharacterBody3D

@onready var cam = get_node("camstandin")

var parentcatapult = null

func _ready():
	if parentcatapult.fps:
		EditorInterface.get_editor_viewport_3d(0).get_parent().grab_focus()
		register_runtime_input("p_fwd",KEY_W)
		register_runtime_input("p_bwd",KEY_S)
		register_runtime_input("p_lft",KEY_A)
		register_runtime_input("p_rht",KEY_D)
		register_runtime_input("p_jmp",KEY_SPACE)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func register_runtime_input(action_name: String, key_code: Key) -> void:
	# 1. Create the action if it doesn't exist yet
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	# 2. Clear existing events if you are doing a runtime key rebind
	InputMap.action_erase_events(action_name)
	
	# 3. Create the physical input event
	var new_key_event := InputEventKey.new()
	new_key_event.physical_keycode = key_code # Use physical_keycode to ignore keyboard layout changes
	
	# 4. Map the event to your action
	InputMap.action_add_event(action_name, new_key_event)

func _process(delta):
	if parentcatapult.fps:
		# Force editor camera alignment
		EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_position = cam.global_position
		EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_rotation = cam.global_rotation
		
		# UNLOCK THE FACE: Fetch accumulated mouse movement directly from the engine singleton 
		# This ignores whether Godot's event system is routing events to this node or not.
		var mouse_delta = Input.get_last_mouse_velocity() * delta
		if mouse_delta != Vector2.ZERO:
			rotation_degrees.y -= mouse_delta.x * 0.05
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x - mouse_delta.y * 0.05, -90, 90)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	if is_on_floor() and Input.is_action_just_pressed("p_jmp"):
		velocity.y = 4.5
		
	var input_dir := Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd")
	if input_dir:
		get_viewport().set_input_as_handled()
		
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if (not abs(velocity.x) > 6.0) or is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * 5.0, 14.0 * delta)
	if (not abs(velocity.z) > 6.0) or is_on_floor():
		velocity.z = lerp(velocity.z, direction.z * 5.0, 14.0 * delta)
	move_and_slide()

# Reverting this completely back to an emergency button
func _input(event):
	if parentcatapult.fps:
		if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
			parentcatapult.fps = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_viewport().set_input_as_handled()

"""
		ts.reload()
		simulatedBody.set_script(ts)
		simulatedBody.parentcatapult = self
		connect("body_entered",praisedrays)
	else:
		super()

func praisedrays(body:Node3D):
	print("BODY ENTERED IN EDITOR! Body:",body.name)
	if body is CharacterBody3D:
		editorPlayer = body
	if body is RigidBody3D:
		editorPlayer = body

func _on_button_clicked() -> void:
	if not simulatedBody.is_inside_tree():
		spos = EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_position
		srot = EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_rotation
		EditorInterface.get_edited_scene_root().add_child(simulatedBody)
		simulatedBody.velocity = Vector3.ZERO
		simulatedBody.global_position = global_position + global_position.direction_to(destination.global_position).normalized()
		simulatedBody.look_at(destination.global_position)
		simulatedBody.rotation.x = 0
		simulatedBody.rotation.z = 0
		simulator = true
	else:
		EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_position = spos
		EditorInterface.get_editor_viewport_3d(0).get_camera_3d().global_rotation = srot
		EditorInterface.get_edited_scene_root().remove_child(simulatedBody)
		simulator = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

var bodies_inside = []

func on_enter(body:Node3D):
	if body is CharacterBody3D:
		print("Checking that ",body.velocity.length()," is above ",minimal_threshold)
		if abs(body.velocity.length()) > minimal_threshold:
			bodies_inside.append(body)
	if body is RigidBody3D:
		if abs(body.linear_velocity.length()) > minimal_threshold:
			bodies_inside.append(body)

func on_exit(_body): pass

var editorPlayer = null

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if simulator:
			#print("Simulating...")
			if simulatedBody is CharacterBody3D:
				simulatedBody.velocity = simulatedBody.global_position.direction_to(destination.global_position) * push_force
			else:
				simulatedBody.linear_velocity = simulatedBody.global_position.direction_to(destination.global_position) * push_force
				simulatedBody.angular_velocity = Vector3.ONE*2
			if destination.global_position.distance_to(simulatedBody.global_position) < 0.25:
				simulator = false
		if editorPlayer != null:
			if editorPlayer is CharacterBody3D:
				editorPlayer.velocity = editorPlayer.global_position.direction_to(destination.global_position) * push_force
			else:
				editorPlayer.linear_velocity = editorPlayer.global_position.direction_to(destination.global_position) * push_force
				editorPlayer.angular_velocity = Vector3.ONE*2
			if destination.global_position.distance_to(editorPlayer.global_position) < 0.25:
				editorPlayer = null
		return
	for body in bodies_inside:
		if not is_instance_valid(body): continue
		if body is CharacterBody3D:
			body.velocity = body.global_position.direction_to(destination.global_position) * push_force
			if destination.global_position.distance_to(body.global_position) < 0.25:
				bodies_inside.erase(body)
		if body is RigidBody3D:
			body.linear_velocity = body.global_position.direction_to(destination.global_position) * push_force
			body.angular_velocity = Vector3.ONE*2
			if destination.global_position.distance_to(body.global_position) < 0.25:
				bodies_inside.erase(body)
				#body.angular_velocity = Vector3.ONE

#func _physics_process(delta):
#	if Engine.is_editor_hint():
#		if simulatedBody.is_inside_tree():
#			simulatedBody._physics_process(delta)

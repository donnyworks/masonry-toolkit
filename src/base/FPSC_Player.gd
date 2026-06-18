extends CharacterBody3D
class_name FPSC_Player

enum FadeTypes{
	FADE_NONE = 0,
	FADE_IN = 1,
	FADE_OUT = 2
}
@export_enum("No Fade","Fade In","Fade Out") var fade_type = 0
@export var fade_color : Color
@export var fade_duration : float = 1.0
@export_group("Player Speed Controls")
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var DRAG = 1.0 ## Drag resistance is used whenever the player is slowing down
@export_group("Player Look Controls")
@export var lookMin = -90
@export var lookMax = 90

var isListenServer = false

static var sessionPlayer : FPSC_Player = null

var currentViewmodel = Node3D.new()

var inventory = [[],[],[],[],[],[]]

var fov_desired = 90

var currentWeapon : FPSC_Weapon = null:
	set(value):
		if value.CanBeEquipped:
			currentWeapon = value
		else:
			print("Feature flag for weapon not enabled, cannot be equipped!")

func FPSC_SetupViewmodel(actual_viewmodel:Node):
	if isSimulated: return
	if currentViewmodel.is_inside_tree():
		$ViewmodelRenderer.remove_child(currentViewmodel)
	$ViewmodelRenderer.add_child(actual_viewmodel)
	currentViewmodel = actual_viewmodel

var LegacyViewMode = false

var health = 100

var paused = false

func dynamo_setup_lightmodel():
	if isSimulated: return
	for light in get_tree().get_nodes_in_group("lights"):
		$ViewmodelRenderer.add_child(light.duplicate())

func dynamo_cam_track():
	if isSimulated: return
	if currentViewmodel != null:
		currentViewmodel.position = $Camera3D.global_position
		currentViewmodel.rotation = $Camera3D.global_rotation
	$ViewmodelRenderer/Camera3D.position = $Camera3D.global_position
	$ViewmodelRenderer/Camera3D.rotation = $Camera3D.global_rotation

func FPSC_GetHitscanRaycast():
	return $Camera3D/RayCast3D

func FPSC_ExecuteFade(fade_color : Color,fade_type : FadeTypes,fade_duration : float):
	if isSimulated: return # No,
	print("Fade type ",fade_type)
	print("for ",fade_duration)
	$TransFade.color = fade_color
	if fade_type != FadeTypes.FADE_NONE and fade_type != 0:
		var t = create_tween()
		if fade_type == FadeTypes.FADE_IN or fade_type == 1:
			$TransFade.self_modulate = Color(1,1,1,1)
			t.tween_property($TransFade,"self_modulate",Color(1,1,1,0),fade_duration)
		if fade_type == FadeTypes.FADE_OUT or fade_type == 2:
			t.tween_property($TransFade,"self_modulate",Color(1,1,1,1),fade_duration)
		await get_tree().create_timer(fade_duration).timeout
		get_tree().paused = false
	else:
		get_tree().paused = false

func _ready():
	isSimulated = Monolyth.isMultiplayer and ((not Monolyth.isClient and not isListenServer) or (Monolyth.isClient and name != str(Monolyth.get_unique_id())))
	if isSimulated:
		var wpn = FPSC_TestWeapon.new()
		currentWeapon = wpn
		get_parent().add_child.call_deferred(wpn)
		return
	get_tree().paused = true
	FPSC_ExecuteFade(fade_color,fade_type,fade_duration)
	LegacyViewMode = not FPSC_BuildFeatures.BuildFeatures.FEATURE_DYNAMO
	if not LegacyViewMode:
		dynamo_setup_lightmodel()
	$Camera3D.fov = fov_desired
	var wpn = FPSC_TestWeapon.new()
	currentWeapon = wpn
	get_parent().add_child.call_deferred(wpn)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sessionPlayer = self
	var button = $MenuGUIElement/TemplateButton
	for item in FPSC_GlobalState.maps_listed:
		var button_item = button.duplicate()
		button_item.visible = true
		button_item.text = "Map: " + item
		button_item.connect("ButtonPressure",MapButtonHandler)
		$MenuGUIElement/GridContainer/MapControls.add_child(button_item)

func MapButtonHandler(btn_name:String):
	paused = false
	get_tree().paused = false
	var mapName = btn_name.replace("Map: ","")
	get_tree().change_scene_to_file(FPSC_GlobalState.maps_listed[mapName])
	pass

var hasPauseFireEnded = false

var mapSelectorMap = 0

var mapNames = FPSC_GlobalState.maps_listed.keys()
var mapPaths = FPSC_GlobalState.maps_listed.values()

var pocket_object = null

var host_object : RigidBody3D = null

func _process(delta):
	isSimulated = Monolyth.isMultiplayer and ((not Monolyth.isClient and not isListenServer) or (Monolyth.isClient and name != str(Monolyth.get_unique_id())))
	if isSimulated:
		$Camera3D.current = false
		$TextureRect.visible = false
		$MapSelectionLabel.visible = false
		$TransFade.visible = false
		return
	if not is_inside_tree(): return
	if not LegacyViewMode:
		dynamo_cam_track()
	$MapSelectionLabel.text = """Map Selector
< %s >""".replace("%s",mapNames[mapSelectorMap])
	if Input.is_action_just_pressed("ui_right"):
		if mapSelectorMap + 1 < len(mapNames):
			mapSelectorMap += 1
		else:
			mapSelectorMap = 0
	if Input.is_action_just_pressed("ui_left"):
		if mapSelectorMap - 1 > -1:
			mapSelectorMap -= 1
		else:
			mapSelectorMap = len(mapNames) - 1
	if Input.is_action_just_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if $ViewmodelRenderer.size != get_tree().root.size:
		$ViewmodelRenderer.size = get_tree().root.size
	if paused:
		$MenuGUIElement.visible = Input.is_action_pressed("p_devmenu")
		if currentWeapon != null:
			if currentWeapon.FPSC_CanPrimaryFire() and not hasPauseFireEnded:
				hasPauseFireEnded = true
				currentWeapon.FPSC_EndPrimaryFire()
			if currentWeapon.FPSC_CanSecondaryFire() and not hasPauseFireEnded:
				hasPauseFireEnded = true
				currentWeapon.FPSC_EndSecondaryFire()
		if Input.is_action_just_pressed("ui_accept"):
			FPSC_LevelManager.ChangeLevel(mapPaths[mapSelectorMap])
		return
	else:
		hasPauseFireEnded = false
	if health <= 0:
		$Camera3D.position.y = -0.2
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	if $Camera3D/RayCast3D.is_colliding():
		$Camera3D/RayCast3D/Sprite3D.global_position = $Camera3D/RayCast3D.get_collision_point()
	if Input.is_action_just_pressed("p_use"):
		if $Camera3D/GrabCast.is_colliding():
			if $Camera3D/GrabCast.get_collider() is RigidBody3D:
				if pocket_object != null:
					host_object.set_physics_process(true)
					host_object.set_physics_process_internal(true)
					host_object.set_process(true)
					host_object.set_process_internal(true)
					host_object.visible = pocket_object.visible
					host_object.collision_layer = pocket_object.collision_layer
					host_object.collision_mask = pocket_object.collision_mask
					host_object.angular_velocity = pocket_object.angular_velocity
					host_object.linear_velocity = pocket_object.linear_velocity
					var host_collider = null
					for object in host_object.get_children():
						if object is CollisionShape3D:
							host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
					host_object.position = $Camera3D/GrabCast.get_collision_point() + $Camera3D/GrabCast.get_collision_normal()*host_collider
					#get_parent().add_child(pocket_object)
					pocket_object = null
					host_object = null
				host_object = $Camera3D/GrabCast.get_collider()
				host_object.set_physics_process(false)
				host_object.set_physics_process_internal(false)
				host_object.set_process(false)
				host_object.set_process_internal(false)
				pocket_object = host_object.duplicate()
				host_object.visible = false
				host_object.collision_layer = 0
				host_object.collision_mask = 0
			else:
				if pocket_object != null:
					host_object.set_physics_process(false)
					host_object.set_physics_process_internal(false)
					host_object.set_process(false)
					host_object.set_process_internal(false)
					host_object.visible = pocket_object.visible
					host_object.collision_layer = pocket_object.collision_layer
					host_object.collision_mask = pocket_object.collision_mask
					var host_collider = null
					for object in host_object.get_children():
						if object is CollisionShape3D:
							host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
					host_object.position = $Camera3D/RayEndpoint.global_position + Vector3(0,1,0)*host_collider
					#get_parent().add_child(pocket_object)
					pocket_object = null
					host_object = null
		else:
			if pocket_object != null:
				host_object.set_physics_process(false)
				host_object.set_physics_process_internal(false)
				host_object.set_process(false)
				host_object.set_process_internal(false)
				host_object.visible = pocket_object.visible
				host_object.collision_layer = pocket_object.collision_layer
				host_object.collision_mask = pocket_object.collision_mask
				host_object.angular_velocity = pocket_object.angular_velocity
				host_object.linear_velocity = pocket_object.linear_velocity
				var host_collider = null
				for object in host_object.get_children():
					print(object.get_class())
					if object is CollisionShape3D:
						host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
						print($Camera3D/GrabCast.get_collision_normal()*host_collider)
				host_object.position = $Camera3D/GrabCast.get_collision_point() + ($Camera3D/GrabCast.get_collision_normal()*host_collider if host_collider != null else Vector3.ZERO)
				#get_parent().add_child(pocket_object)
				pocket_object = null
				host_object = null
	if currentWeapon == null: return
	if $Camera3D/RayCast3D.is_colliding():
		if $Camera3D/RayCast3D.get_collider() is FPSC_Weapon: # Gotta love how we have dedicated functions coded for sourcebox
			$Camera3D/RayCast3D.get_collider().FPSC_WeaponOnPickerHover()
	if Input.is_action_just_pressed("p_fire"):
		if currentWeapon.FPSC_CanPrimaryFire():
			currentWeapon.FPSC_StartPrimaryFire()
	if Input.is_action_pressed("p_fire"):
		if currentWeapon.FPSC_CanPrimaryFire():
			currentWeapon.FPSC_PrimaryFire()
	if Input.is_action_just_pressed("p_alt"):
		if currentWeapon.FPSC_CanSecondaryFire():
			currentWeapon.FPSC_StartSecondaryFire()
	if Input.is_action_pressed("p_alt"):
		if currentWeapon.FPSC_CanSecondaryFire():
			currentWeapon.FPSC_SecondaryFire()
	if Input.is_action_just_released("p_fire"):
		if currentWeapon.FPSC_CanPrimaryFire():
			currentWeapon.FPSC_EndPrimaryFire()
	if Input.is_action_just_released("p_alt"):
		if currentWeapon.FPSC_CanSecondaryFire():
			currentWeapon.FPSC_EndSecondaryFire()
	if Input.is_action_just_pressed("p_reload"):
		currentWeapon.FPSC_Reload()
	if Input.is_action_just_pressed("ui_accept"):
		FPSC_LevelManager.ChangeLevel(mapPaths[mapSelectorMap])

var stored_jump = false
var stored_movedir = Vector2.ZERO

func modify_velocity(is_jumping:bool,move_vector:Vector2,delta:float):
	
	if is_jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := move_vector
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not abs(velocity.x) > SPEED: velocity.x = direction.x * SPEED
		if not abs(velocity.z) > SPEED: velocity.z = direction.z * SPEED
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, SPEED, DRAG*delta)
			velocity.z = move_toward(velocity.z, SPEED, DRAG*delta)

var isSimulated = Monolyth.isMultiplayer and not Monolyth.isClient and not isListenServer

var isBeingFlung = false

func FPSC_GetMPState():
	if Monolyth.isClient:
		return null
	else:
		return [velocity,position,rotation,currentWeapon.FPSC_GetMPState()]

func FPSC_ApplyMPState(state):
	if not Monolyth.isClient:
		return
	else:
		if abs(position.distance_to(state[1])) > 4.0: # That's a little extreme. No amount of prediction can save this.
			position = state[1]
		if name == str(Monolyth.get_unique_id()): return
		velocity = state[0]
		#position = state[1]
		rotation = state[2] # We ignore rotation as self to prevent weird race conditions
		currentWeapon.FPSC_ApplyMPState(state[3])

func FPSC_GetInputs():
	return [Input.is_action_just_pressed("p_jmp"),Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd")]

func FPSC_ApplyInputs(m_args):
	stored_jump = m_args[0]
	stored_movedir = m_args[1]
	rotation = m_args[2]

func _physics_process(delta: float) -> void:
	if not is_inside_tree(): return
	if paused: return
	if health <= 0: return
	isSimulated = Monolyth.isMultiplayer and ((not Monolyth.isClient and not isListenServer) or (Monolyth.isClient and name != str(Monolyth.get_unique_id())))
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not Monolyth.isMultiplayer:
		modify_velocity(Input.is_action_just_pressed("p_jmp"),Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd"),delta)
	
	# Handle jump.
	if Monolyth.isMultiplayer and not Monolyth.isClient:
		if isSimulated: # All this boils down to: if we're the server and not the listen server, don't simulate
			modify_velocity(stored_jump,stored_movedir,delta)
		else:
			modify_velocity(Input.is_action_just_pressed("p_jmp"),Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd"),delta)
	elif Monolyth.isMultiplayer and Monolyth.isClient and not isSimulated:
		Monolyth.SendMessage("FPSC_UpdatePlayState",[Input.is_action_just_pressed("p_jmp"),Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd"),rotation],1)
		modify_velocity(Input.is_action_just_pressed("p_jmp"),Input.get_vector("p_lft", "p_rht", "p_fwd", "p_bwd"),delta)
		# We simulate movement on the client side as well as sending it to the server
	move_and_slide()

func _input(event):
	if not is_inside_tree(): return
	if isSimulated: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x
		$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x - event.relative.y,lookMin,lookMax)

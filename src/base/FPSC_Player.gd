extends CharacterBody3D
class_name FPSC_Player

enum FadeTypes{
	FADE_NONE = 0,
	FADE_IN = 1,
	FADE_OUT = 2
}
@export var entrance_number := 0 ## Determines which entrance to use. See FPSC_TriggerChangelevel.
@export_group("Fade Controls")
@export_enum("No Fade","Fade In","Fade Out") var fade_type = 0
@export var fade_color : Color
@export var fade_duration : float = 1.0
@export_group("Player Move Control")
@export var can_crouch := true
@export_group("Player Speed Controls")
@export var SPEED = 5.0
@export var SPEED_SPRINT = 6.0
@export var SPEED_CROUCH = 4.0
@export var JUMP_VELOCITY = 4.5
@export var accel = 14 ## This variable was taken from SMORCE 3. The movement was smoother there, so that's why I took it.
@export var DRAG = 1.0 ## Drag resistance is used whenever the player is slowing down
@export var velocity_music : AudioStream
@export var velocity_music_threshold : float = 10.0
@export_group("Player Look Controls")
@export var lookMin = -90
@export var lookMax = 90

var footsteps = [preload("res://sound/player/footsteps1.wav"),preload("res://sound/player/footsteps2.wav"),preload("res://sound/player/footsteps3.wav")]

func chooseRandomFromArray(array:Array):
	return array[randi_range(0,len(array) - 1)]

static var base_speed = 5.0
static var base_jv = 4.5
static var base_speed_sprint = 6.0
static var base_speed_crouch = 4.0

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

var health = 100:
	set(v):
		if v <= 0:
			FPSC_ExecuteFade(Color(1,0,0,0.5),FadeTypes.FADE_IN,2)
			$death.play()
			FPSC_CaptionSystem.FPSC_AddCaptionLine("Player.Death")
		health = v

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
		t.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
		if fade_type == FadeTypes.FADE_IN or fade_type == 1:
			$TransFade.self_modulate = Color(1,1,1,1)
			t.tween_property($TransFade,"self_modulate",Color(1,1,1,0),fade_duration)
		if fade_type == FadeTypes.FADE_OUT or fade_type == 2:
			t.tween_property($TransFade,"self_modulate",Color(1,1,1,1),fade_duration)
		await get_tree().create_timer(fade_duration).timeout
		get_tree().paused = false
	else:
		get_tree().paused = false

func FPSC_ShowChapterTitle(title:String,color:Color,duration:float,subtext=""):
	title = FPSC_LocalizationSystem.FPSC_GetLocalString(title)
	subtext = FPSC_LocalizationSystem.FPSC_GetLocalString(subtext)
	$ChapterTitle.self_modulate = color
	$ChapterTitle.text = ""
	for character in title:
		$ChapterTitle.text += " "
	$ChapterTitle.text += "\n"
	for character in subtext:
		$ChapterTitle.text += " "
	var idx = 0
	var inBrackets = false
	@warning_ignore("shadowed_global_identifier")
	for char in range(0,len(title)):
		$ChapterTitle.text[char] = title[char]
		if title[char] == "[": inBrackets = true
		if title[char] == "]": inBrackets = false
		if not inBrackets: await get_tree().create_timer(0.01, true, false).timeout
		idx += 1
	idx += 1
	inBrackets = false
	for char in range(0,len(subtext)):
		$ChapterTitle.text[idx + char] = subtext[char]
		if subtext[char] == "[": inBrackets = true
		if subtext[char] == "]": inBrackets = false
		if not inBrackets: await get_tree().create_timer(0.01, true, false).timeout
	await get_tree().create_timer(duration).timeout
	var f = create_tween()
	f.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	var new_color = color
	new_color.a = 0
	f.tween_property($ChapterTitle,"self_modulate",new_color,0.5)

func _ready():
	if entrance_number != FPSC_LevelManager.entrance_number:
		queue_free()
		return
	$velocity.stream = velocity_music
	$velocity.autoplay = true
	$velocity.playing = true
	base_speed = SPEED
	base_jv = JUMP_VELOCITY
	base_speed_sprint = SPEED_SPRINT
	base_speed_crouch = SPEED_CROUCH
	FPSC_ConsoleInstance.stale_mode = Input.MOUSE_MODE_CAPTURED
	$MapSelectionLabel.visible = FPSC_BuildFeatures.BuildFeatures.FEATURE_MAPSELECTOR
	isSimulated = Monolyth.isMultiplayer and ((not Monolyth.isClient and not isListenServer) or (Monolyth.isClient and name != str(Monolyth.get_unique_id())))
	if isSimulated:
		@warning_ignore("confusable_local_declaration")
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
	var button_item = button.duplicate()
	button_item.visible = true
	button_item.text = "Open Doors On Use"
	button_item.connect("ButtonPressure",PlayerButtonHandler)
	$MenuGUIElement/GridContainer/PlayerControls.add_child(button_item)

var allow_open_on_use = false

func PlayerButtonHandler(btn_name:String):
	if btn_name == "Open Doors On Use":
		allow_open_on_use = not allow_open_on_use

func MapButtonHandler(btn_name:String):
	paused = false
	get_tree().paused = false
	var mapName = btn_name.replace("Map: ","")
	get_tree().change_scene_to_file(FPSC_GlobalState.maps_listed[mapName])
	pass

func get_collision_polygon_volume(poly_3d: CollisionPolygon3D) -> float:
	var points = poly_3d.polygon
	# A polygon needs at least 3 points to have an area
	if points.size() < 3:
		return 0.0
	
	var area = 0.0
	var num_points = points.size()
	
	# Shoelace formula to calculate 2D polygon area
	for i in range(num_points):
		var p1 = points[i]
		var p2 = points[(i + 1) % num_points] # Loops back to the first point at the end
		area += (p1.x * p2.y) - (p2.x * p1.y)
		
	area = abs(area) * 0.5
	
	# Volume = 2D Area * Extrusion Depth
	return area * poly_3d.depth
var hasPauseFireEnded = false

var mapSelectorMap = 0

var mapNames = FPSC_GlobalState.maps_listed.keys()
var mapPaths = FPSC_GlobalState.maps_listed.values()

var camera_fov_extents = [75.0, 85.0]

var pocket_object = null

var host_object : RigidBody3D = null

var sprinting = false

var state_nukecode = [false,false,false,false,false,false,false,false,false]

func scanForThisDoor(door:CSGShape3D,node:Node):
	for object in node.get_children():
		if object is FPSC_DoorActivatable:
			if object.object_as_door == door:
				object.on_enter(self)
		else:
			scanForThisDoor(door,object)

func recurse_nuke(node:Node):
	for n in node.get_children():
		if n.has_method("FPSC_GetMPState"):
			if n is Node3D:
				n.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.visible = not randi_range(0,100) == 50
			if n is FPSC_DoorActivatable or n is FPSC_RotatingDoorActivatable:
				var nn = n.object_as_door
				nn.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.visible = not randi_range(0,100) == 50
		if n is RigidBody3D:
			n.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.visible = not randi_range(0,100) == 50
			if n is Node3D:
				n.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				n.visible = not randi_range(0,100) == 50
			if n is FPSC_DoorActivatable or n is FPSC_RotatingDoorActivatable:
				var nn = n.object_as_door
				nn.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
				nn.visible = not randi_range(0,100) == 50
		if n is FPSC_Trigger:
			n.position += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.rotation += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.scale += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
			n.visible = not randi_range(0,100) == 50
		if n is CanvasItem:
			n.position += Vector2(randf_range(-1,1),randf_range(-1,1))
			n.rotation += randf_range(-1,1)
			n.scale += Vector2(randf_range(-1,1),randf_range(-1,1))
			n.visible = not randi_range(0,100) == 50
		recurse_nuke(n)
			

var templatePauseMenu = preload("res://instances/mainmenu.tscn")

var pausemenu = null

func _process(delta):
	isSimulated = Monolyth.isMultiplayer and ((not Monolyth.isClient and not isListenServer) or (Monolyth.isClient and name != str(Monolyth.get_unique_id())))
	if isSimulated:
		#print("Simulating character " + name)
		$Camera3D.current = false
		$TextureRect.visible = false
		$MapSelectionLabel.visible = false
		$TransFade.visible = false
		return
	if not is_inside_tree(): return
	if not LegacyViewMode:
		dynamo_cam_track()
	$velocity.volume_linear = min(max((velocity.length() - SPEED_SPRINT)/velocity_music_threshold,0.0),1.0)
	camera_fov_extents = [FPSC_LevelManager.fov, FPSC_LevelManager.fov + 10.0]
	$MapSelectionLabel.text = """Map Selector
< %s >""".replace("%s",mapNames[mapSelectorMap])
	if Input.is_action_just_pressed("ui_right") and FPSC_BuildFeatures.BuildFeatures.FEATURE_MAPSELECTOR:
		if mapSelectorMap + 1 < len(mapNames):
			mapSelectorMap += 1
		else:
			mapSelectorMap = 0
	if Input.is_action_just_pressed("ui_left") and FPSC_BuildFeatures.BuildFeatures.FEATURE_MAPSELECTOR:
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
		if pausemenu == null and not FPSC_ConsoleInstance.visible:
			pausemenu = templatePauseMenu.duplicate().instantiate()
			add_child(pausemenu)
		$MenuGUIElement.visible = Input.is_action_pressed("p_devmenu")
		if currentWeapon != null:
			if currentWeapon.FPSC_CanPrimaryFire() and not hasPauseFireEnded:
				hasPauseFireEnded = true
				currentWeapon.FPSC_EndPrimaryFire()
			if currentWeapon.FPSC_CanSecondaryFire() and not hasPauseFireEnded:
				hasPauseFireEnded = true
				currentWeapon.FPSC_EndSecondaryFire()
		if Input.is_action_just_pressed("ui_accept") and FPSC_BuildFeatures.BuildFeatures.FEATURE_MAPSELECTOR:
			FPSC_LevelManager.ChangeLevel(mapPaths[mapSelectorMap])
		return
	else:
		if pausemenu != null:
			pausemenu.cancel()
			pausemenu.queue_free()
			pausemenu = null
		hasPauseFireEnded = false
	if Input.is_action_just_pressed("p_fwd") and FPSC_LevelManager.interloping:
		if not state_nukecode[0]:
			state_nukecode[0] = true
		else:
			if state_nukecode[1]:
				state_nukecode[2] = true
			else:
				state_nukecode[0] = false
				state_nukecode[1] = false
	if Input.is_action_just_pressed("p_bwd"):
		if state_nukecode[0] and not state_nukecode[1]:
			state_nukecode[1] = true
		else:
			state_nukecode[0] = false
			state_nukecode[1] = false
	if Input.is_action_just_pressed("p_rht"):
		if state_nukecode[3]:
			state_nukecode[4] = true
		else:
			state_nukecode[3] = true
	if Input.is_action_just_pressed("p_lft"):
		if state_nukecode[4]:
			state_nukecode[5] = true
		else:
			state_nukecode[3] = false
	if Input.is_action_just_pressed("p_jmp"):
		if state_nukecode[5]:
			state_nukecode[6] = true
		else:
			state_nukecode[4] = false
	if Input.is_action_just_pressed("p_flashlight"):
		if state_nukecode[7]:
			recurse_nuke(get_tree().current_scene)
			pass # todo: flashnuke
		if state_nukecode[6]:
			state_nukecode[7] = true
		
	if health <= 0:
		$Camera3D.position.y = -0.2
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	if $Camera3D/RayCast3D.is_colliding():
		$Camera3D/RayCast3D/Sprite3D.global_position = $Camera3D/RayCast3D.get_collision_point()
	if host_object != null:
		host_object.visible = FPSC_LevelManager.propvis
		if $Camera3D/GrabCast.is_colliding():
			var host_collider = null
			for object in host_object.get_children():
				if object is CollisionShape3D:
					host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
				if object is CollisionPolygon3D:
					host_collider = get_collision_polygon_volume(object)
			host_object.global_position = $Camera3D/GrabCast.get_collision_point() + $Camera3D/GrabCast.get_collision_normal()*host_collider
			host_object.freeze = true
		else:
			host_object.freeze = true
			host_object.global_position = $Camera3D/RayEndpoint.global_position
	if Input.is_action_just_pressed("p_use"):
		if $Camera3D/GrabCast.is_colliding():
			if $Camera3D/GrabCast.get_collider() is RigidBody3D:
				if pocket_object != null and host_object != null:
					host_object.set_physics_process(true)
					host_object.set_physics_process_internal(true)
					host_object.set_process(true)
					host_object.set_process_internal(true)
					host_object.visible = pocket_object.visible
					host_object.collision_layer = pocket_object.collision_layer
					host_object.collision_mask = pocket_object.collision_mask
					host_object.angular_velocity = pocket_object.angular_velocity
					host_object.linear_velocity = pocket_object.linear_velocity
					host_object.freeze = false
					var host_collider = null
					for object in host_object.get_children():
						if object is CollisionShape3D:
							host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
						if object is CollisionPolygon3D:
							host_collider = get_collision_polygon_volume(object)
					host_object.global_position = $Camera3D/GrabCast.get_collision_point() + $Camera3D/GrabCast.get_collision_normal()*host_collider
					#get_parent().add_child(pocket_object)
					pocket_object = null
					host_object = null
				host_object = $Camera3D/GrabCast.get_collider()
				if not host_object.freeze and not host_object.is_in_group("Non-Pickup"):
					host_object.set_physics_process(false)
					host_object.set_physics_process_internal(false)
					host_object.set_process(false)
					host_object.set_process_internal(false)
					pocket_object = host_object.duplicate()
					host_object.visible = false
					host_object.collision_layer = 0
					host_object.collision_mask = 0
			elif $Camera3D/GrabCast.get_collider() is CSGShape3D and allow_open_on_use and host_object == null and pocket_object == null:
				# lag the game
				scanForThisDoor($Camera3D/GrabCast.get_collider(),get_tree().current_scene)
			else:
				if pocket_object != null and host_object != null:
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
						if object is CollisionPolygon3D:
							host_collider = get_collision_polygon_volume(object)
					host_object.global_position = $Camera3D/RayEndpoint.global_position
					host_object.freeze = false
					#get_parent().add_child(pocket_object)
					pocket_object = null
					host_object = null
			if $Camera3D/GrabCast.get_collider() is CSGShape3D:
				for object in $Camera3D/GrabCast.get_collider().get_children():
					if object is FPSC_InteractivityMarker:
						object.activatable.on_enter(self)
		else:
			if pocket_object != null and host_object != null:
				host_object.set_physics_process(false)
				host_object.set_physics_process_internal(false)
				host_object.set_process(false)
				host_object.set_process_internal(false)
				host_object.visible = pocket_object.visible
				host_object.collision_layer = pocket_object.collision_layer
				host_object.collision_mask = pocket_object.collision_mask
				host_object.angular_velocity = pocket_object.angular_velocity
				host_object.linear_velocity = pocket_object.linear_velocity
				host_object.freeze = false
				var host_collider = null
				for object in host_object.get_children():
					print(object.get_class())
					if object is CollisionShape3D:
						host_collider = object.shape.get_debug_mesh().get_aabb().get_volume()
						print($Camera3D/GrabCast.get_collision_normal()*host_collider)
					if object is CollisionPolygon3D:
						host_collider = get_collision_polygon_volume(object)
				host_object.global_position = $Camera3D/RayEndpoint.global_position
				#host_object.position = $Camera3D/GrabCast.get_collision_point() + ($Camera3D/GrabCast.get_collision_normal()*host_collider if host_collider != null else Vector3.ZERO)
				#get_parent().add_child(pocket_object)
				pocket_object = null
				host_object = null
			else:
				FPSC_CaptionSystem.FPSC_AddCaptionLine("Player.InteractionFailed")
	# SMORCE 3 / FPS CONTROLLER TEMPLATE
	if Input.is_action_pressed("p_zoom"):
		camera_fov_extents[0] = 30.0
	else:
		camera_fov_extents[0] = 75.0
	if abs(velocity.x) > base_speed or abs(velocity.z) > base_speed:
		$Camera3D.fov = lerp($Camera3D.fov, camera_fov_extents[1], 10*delta)
	else:
		$Camera3D.fov = lerp($Camera3D.fov, camera_fov_extents[0], 10*delta)
	if Input.is_action_pressed("p_run"):
		sprinting = true
		SPEED = SPEED_SPRINT
		$CollisionShape3D.shape.height = 2.0
	else:
		sprinting = false
		SPEED = base_speed
		if Input.is_action_pressed("p_crouch"):
			if can_crouch:
				SPEED = SPEED_CROUCH
				$CollisionShape3D.shape.height = 0.7*2.0
		else:
			SPEED = base_speed
			$CollisionShape3D.shape.height = 2.0
	if Input.is_action_just_pressed("ui_accept") and FPSC_BuildFeatures.BuildFeatures.FEATURE_MAPSELECTOR:
		FPSC_LevelManager.ChangeLevel(mapPaths[mapSelectorMap])
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

var stored_jump = false
var stored_movedir = Vector2.ZERO

func modify_velocity(is_jumping:bool,move_vector:Vector2,delta:float):
	if not noclip:
		if is_jumping and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := move_vector
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction and is_on_floor() and not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.stream = chooseRandomFromArray(footsteps)
			$AudioStreamPlayer3D.play()
		if not direction or not is_on_floor():
			if $AudioStreamPlayer3D.playing:
				$AudioStreamPlayer3D.stop()
		if (not abs(velocity.x) > SPEED_SPRINT) or is_on_floor(): velocity.x = lerp(velocity.x, direction.x * SPEED, accel * delta)
		if (not abs(velocity.z) > SPEED_SPRINT) or is_on_floor(): velocity.z = lerp(velocity.z, direction.z * SPEED, accel * delta)
	else:
		var input_dir := move_vector
		var direction := (transform.basis * Vector3(input_dir.x, 1, input_dir.y)).normalized()
		if (not abs(velocity.x) > SPEED_SPRINT) or is_on_floor(): velocity.x = lerp(velocity.x, direction.x * SPEED, accel * delta)
		if (not abs(velocity.x) > SPEED_SPRINT) or is_on_floor(): velocity.y = lerp(velocity.y, direction.y * SPEED, accel * delta)
		if (not abs(velocity.z) > SPEED_SPRINT) or is_on_floor(): velocity.z = lerp(velocity.z, direction.z * SPEED, accel * delta)
	#if direction:
		#if not abs(velocity.x) > SPEED: velocity.x = direction.x * SPEED
		#if not abs(velocity.z) > SPEED: velocity.z = direction.z * SPEED
	#else:
	#	if is_on_floor():
	#		velocity.x = move_toward(velocity.x, 0, SPEED)
	#		velocity.z = move_toward(velocity.z, 0, SPEED)


var isSimulated = Monolyth.isMultiplayer and not Monolyth.isClient and not isListenServer

var isBeingFlung = false

func FPSC_GetMPState():
	if Monolyth.isClient and FPSC_LevelManager.demoname == "":
		return null
	else:
		return [velocity,position,rotation,$Camera3D.rotation,currentWeapon.FPSC_GetMPState() if currentWeapon != null else [],Input.is_action_pressed("p_crouch"), noclip]

func FPSC_ApplyMPState(state):
	if not Monolyth.isClient and FPSC_LevelManager.demo_data == {}:
		return
	else:
		#print("posd: ",position.distance_to(state[1]))
		#print("pos: ",position)
		#print("d: ",state[1])
		if FPSC_LevelManager.demo_freeroam and FPSC_LevelManager.demo_data != {}:
			return # no.
		if abs(position.distance_to(state[1])) > 5.0: # That's a little extreme. No amount of prediction can save this.
			position = state[1]
		if FPSC_LevelManager.demo_data == {}:
			if name == str(Monolyth.get_unique_id()): return
		velocity = state[0]
		position = state[1]
		if FPSC_LevelManager.demo_freelook and FPSC_LevelManager.demo_data != {}:
			if currentWeapon != null: currentWeapon.FPSC_ApplyMPState(state[4])
			if state[5]:
				if can_crouch:
					SPEED = SPEED_CROUCH
					$CollisionShape3D.shape.height = 0.7*2.0
			return
		rotation = state[2] # We ignore rotation as self to prevent weird race conditions
		$Camera3D.rotation = state[3]
		if currentWeapon != null: currentWeapon.FPSC_ApplyMPState(state[4])
		if state[5]:
			if can_crouch:
				SPEED = SPEED_CROUCH
				$CollisionShape3D.shape.height = 0.7*2.0
		if len(state) > 6:
			noclip = state[6]

var noclip = false

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
	if FPSC_LevelManager.interloper_active and FPSC_LevelManager.type != 4:
		modify_velocity(stored_jump,stored_movedir,delta)
	else:
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
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# 3. Check if the object we bumped into is a RigidBody
		# Use RigidBody2D for 2D projects
		if collider is RigidBody3D: 
			# Calculate the push direction (away from the player)
			var push_dir = -collision.get_normal()
			
			# Define how heavy/strong the push force should be
			var push_force = 2.0 
			
			# Apply an impulse to the RigidBody
			# For 2D: collider.apply_impulse(push_dir * push_force)
			collider.apply_impulse(push_dir * push_force, collision.get_position() - collider.global_position)
func _input(event):
	if not is_inside_tree(): return
	if isSimulated: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x*FPSC_LevelManager.sensitivity
		$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x - event.relative.y*FPSC_LevelManager.sensitivity,lookMin,lookMax)

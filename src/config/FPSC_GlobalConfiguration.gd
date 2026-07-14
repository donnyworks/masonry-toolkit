extends Node
class_name FPSC_GlobalState

static var maps_listed = {"Waiting to Pear":""}

static var metadata = {}

static func FPSC_LoadGameConfig():
	metadata = JSON.parse_string(FileAccess.get_file_as_string("res://resources/FPSC_GameMetadata.json"))
	maps_listed = metadata.DebugMapList

var target_scene_path: String
var is_loading: bool = false

@onready var setters = [FPSC_MultiplayerFramework, FPSC_LocalizationSystem]

signal LevelChanged()

var sensitivity := 1.0

var VPKH = VPKHandler.CFileAccess

var source_mount_path = ""

var entrance_number := 0 ## The number of the player's entry point. Used for multi-entrance levels.

func gameinfo_process(set_source_mount_path,source_game_path):
	source_mount_path = set_source_mount_path
	var d_gameinfo = FileAccess.get_file_as_string(source_mount_path + "/" + source_game_path + "/gameinfo.txt").replace("\r","").replace("\t","$TAB$").replace("|all_source_engine_paths|","").replace("|gameinfo_path|",source_game_path + "/")
	var gameinfo = d_gameinfo.split("\n")
	VPKHandler.setup_cfa_from_game_path(source_mount_path + "/" + source_game_path)
	#print(VPKHandler.get_archive_from_path("bsp_loader_test.vpk").VPKFileTree.datastruct)
	#L_ProgressBar.set_deferred("max_value",(len(d_gameinfo.split("$TAB$game")) - 1)/2)
	BSPHandler.FA = VPKHandler.CFileAccess
	VTFHandler.FA = VPKHandler.CFileAccess
	VPKH = VPKHandler.CFileAccess
	VPKHandler.append_archive_to_cfa(source_mount_path + "/" + source_game_path + "/pak01.vpk")
	for line in gameinfo:
		if line.replace("$TAB$","").begins_with("game"):
			DisplayServer.window_set_title(line.split("$TAB$")[len(line.split("$TAB%")) - 1].replace("\"",""))
		if line.replace("$TAB$","").begins_with("game"): # GAME+MOD?!
			var file_path = line.split("$TAB$")[len(line.split("$TAB$")) - 1]
			print("[GameInfo Processing Pipeline] Processing " + file_path)
			#L_Label.set_deferred("text","Processing " + file_path)
			#L_ProgressBar.set_deferred("value",L_ProgressBar.value + 1)
			print("Checking path ",file_path)
			print("FS ref: ",(source_mount_path + "/" + file_path))
			print("Also checking for ",source_mount_path + "/" + file_path.replace(".vpk","_dir.vpk"))
			var FILE_EXISTS_RAW = FileAccess.file_exists(source_mount_path + "/" + file_path)
			var FILE_EXISTS_DIR = FileAccess.file_exists(source_mount_path + "/" + file_path.replace(".vpk","_dir.vpk"))
			print("Results: ",FILE_EXISTS_RAW," and ",FILE_EXISTS_DIR)
			if (FILE_EXISTS_RAW or FILE_EXISTS_DIR) and file_path.ends_with(".vpk"):
				print("Adding file ",file_path)
				VPKHandler.append_archive_to_cfa(source_mount_path + "/" + file_path)

var current_entities = []

var current_player = null

func LoadBSPFile(path):
	var dummy_scene = Node3D.new()
	get_node("/root").add_child(dummy_scene)
	get_tree().current_scene = dummy_scene
	var bsp_file = BSPHandler.LoadBSP(path)
	bsp_file.source_game_path = source_mount_path
	var lump_entities : BSPHandler.BSPLumpEntities = bsp_file.lumps[BSPHandler.BSPLumps.LUMP_ENTITIES]
	var player_spawn_pos : Vector3
	for entity in lump_entities.entities:
		if entity != {} and "classname" in entity.keys():
			if entity.classname in BSPLoader_Entities.entity_nodes.keys():
				if entity.classname == "worldspawn":
					var cent = BSPLoader_Entities.entity_nodes[entity.classname].duplicate().instantiate()
					var bspmdl_0 = BSPHandler.get_model_mesh_and_lightmap(bsp_file,0)
					var bspmdl = bspmdl_0[0]
					#var bspmdl = BSPHandler.get_model_mesh(bsp_file,0)
					#cent.edict.collision_model = BSPHandler.get_model_concave_collision_mesh(bsp_file,0)
					cent.edict.collision_model = bspmdl_0[0].create_trimesh_shape()
					cent.model = bspmdl
					cent.edict = entity
					current_entities.append(cent)
					#bspmdl_0[1].save_png("user://despair.png")
					#var layered = Texture2DArray.new()
					#layered.create_from_images([bspmdl_0[1]])
					#cent.edict.lightmap = layered
					#cent.edict._lightmap = bspmdl_0[1]
				elif entity.classname == "info_player_start" or entity.classname == "info_player_teamspawn":
					if current_player != null:
						current_entities.erase(current_player)
					var mesh = BSPLoader_Entities.entity_nodes[entity.classname].duplicate().instantiate()
					if "origin" in entity.keys():
						mesh.position += entity.origin / 53
						if player_spawn_pos != Vector3.ZERO:
							mesh.position = player_spawn_pos
					if "angles" in entity.keys(): mesh.rotation_degrees = entity.angles
					current_entities.append(mesh)
					current_player = mesh
				else:
					var mesh = BSPLoader_Entities.entity_nodes[entity.classname].duplicate().instantiate()
					mesh.edict = entity
					if "model" in entity.keys():
						if entity.model.begins_with("*"):
							entity.collision_model = BSPHandler.get_model_collision_mesh(bsp_file,int(entity.model.replace("*","")))
							mesh.model = BSPHandler.get_model_mesh(bsp_file,int(entity.model.replace("*","")))
					if "targetname" in entity.keys():
						mesh.name = entity.targetname
						#if entity.targetname in EntityLookupByName:
						#	EntityLookupByName[entity.targetname].append(mesh)
						#else:
						#	EntityLookupByName[entity.targetname] = [mesh]
					if "origin" in entity.keys(): mesh.position += entity.origin / 53
					if "angles" in entity.keys(): mesh.rotation_degrees = entity.angles
					print(mesh.rotation_degrees)
					if mesh.has_method("init_hooks"):
						mesh.init_hooks(self)
					current_entities.append(mesh)
	for entity in current_entities:
		if not entity.is_inside_tree(): dummy_scene.add_child(entity)

var console = null

func cmd_print(arg):
	print("[CONSOLE] ",arg)
	if console is Callable:
		console.call(str(arg))

const MTK_Version = 8

var demoname = ""

var demo_starttime = 0.0

var demo_data = {}

var current_frame = 0

var interloping = false

var interloper_active = false

var randomPos = Vector3.ZERO

var randomInitialRotation = Vector3.ZERO

var type = 0

var registered_commands = {}

func cmd_map(cmda):
	cmd_print("Changing level to " + cmda[1])
	if FileAccess.file_exists("res://maps/" + cmda[1] + ".tscn"):
		FPSC_LevelManager.ChangeLevel("res://maps/" + cmda[1] + ".tscn")
		if FPSC_MultiplayerFramework.maxplayers > 1: # We're trying to enroll as a server
			await FPSC_LevelManager.LevelChanged
			print("Full assurance that the game has started, the level has loaded, and we are ready to start listening.")
			FPSC_MultiplayerFramework.start_server()
	else:
		if VPKH.file_exists("maps/" + cmda[1] + ".bsp"):
			get_tree().unload_current_scene()
			LoadBSPFile("maps/" + cmda[1] + ".bsp")

func cmd_connect(cmda):
	FPSC_LevelManager.drop_current_level()
	FPSC_MultiplayerFramework.start_client(cmda[1])

func cmd_record(cmda):
	demoname = cmda[1]
	cmd_print("Forcing full state update!")
	FPSC_MultiplayerFramework.cached_entities = []
	FPSC_MultiplayerFramework.build_tree(get_tree().current_scene)
	demo_starttime = Time.get_unix_time_from_system()

func cmd_stop(cmda):
	if demoname != "":
		savedemo()
		cmd_print("Demo length: " + str(Time.get_unix_time_from_system() - demo_starttime))
		cmd_print("Demo length (in demo frames): " + str(round((Time.get_unix_time_from_system() - demo_starttime)/demo_frame_interval)))
	demoname = ""
	demo_timeline = []

func cmd_playdemo(cmda):
	if demoname != "":
		CMDLine("stop")
	if FileAccess.file_exists("user://" + cmda[1] + ".mdemo"):
		cmd_print("Playing demo " + cmda[1])
		#{"version","map","demo_frame_interval","demo_timeline","demo_record_time","demo_length"}
		var f = FileAccess.open("user://" + cmda[1] + ".mdemo",FileAccess.READ)
		var _demo_data = f.get_var()
		f.close()
		current_frame = 0
		print("DEBUG stats:")
		print("Demo was made in Masonry Toolkit version ",_demo_data.version)
		print("Demo was shot in ",_demo_data.map)
		print("Demo finished recording at ",Time.get_datetime_string_from_datetime_dict(_demo_data.demo_record_time,true))
		print("Demo is ",_demo_data.demo_length," seconds long.")
		demo_frame_interval = _demo_data.demo_frame_interval
		#print("Demo data (this will be a big one!!): ",demo_data.demo_timeline)
		ChangeLevel(_demo_data.map)
		await LevelChanged
		demo_data = _demo_data
	else:
		cmd_print("File not found: " + cmda[1])

func cmd_setdemo_framerate(cmda):
	demo_frame_interval = 1/float(cmda[1])

func cmd_setdemo_freeroam(cmda):
	demo_freeroam = cmda[1] == "1" or cmda[1] == "true"

func cmd_setdemo_freelook(cmda):
	demo_freelook = cmda[1] == "1" or cmda[1] == "true"

func cmd_version(cmda):
	cmd_print("Godot Engine version " + Engine.get_version_info().string)
	cmd_print("Masonry Toolkit version " + str(MTK_Version))
	cmd_print(metadata.GameName + " version " + metadata.Version)

func cmd_bsploader_mount(cmda):
	cmd_print("MTK >WILL< lock up while this is loading!")
	gameinfo_process(cmda[1],cmda[2])

func cmd_noclip(_cmda):
	if FPSC_Player.sessionPlayer != null:
		FPSC_Player.sessionPlayer.noclip = not FPSC_Player.sessionPlayer.noclip
		cmd_print("noclip " + ("ON" if FPSC_Player.sessionPlayer.noclip else "OFF"))

func cmd_help(cmda):
	if len(cmda) < 2:
		cmd_print("Masonry Toolkit version " + str(MTK_Version))
		for key in registered_commands:
			cmd_print(key + ": " + registered_commands[key][1])
	else:
		if cmda[1] in registered_commands.keys():
			cmd_print(cmda[1] + ": " + registered_commands[cmda[1]][1])

func CMDLine(command:String):
	var cmda = command.split(" ")
	var cmd_found = false
	for key in registered_commands:
		if cmda[0] == key:
			registered_commands[key][0].call(cmda)
			cmd_found = true
	if cmda[0] == "INTERLOPE":
		interloping = true
		cmd_found = true
	if cmda[0] == "get" and interloping:
		if cmda[1] == "s.interlope.pull:22012":
			# Choose a random map
			var map = ""
			var maps = []
			var filename = "data"
			var index = 1
			var randtype = randi_range(0,100)
			#type = 3 # Temporary, just for testing.
			if randtype < 50: type = 1
			if randtype > 50 and randtype < 80: type = 2
			if randtype > 80 and randtype < 90: type = 3
			if randtype > 90: type = 4
			randomInitialRotation.y = deg_to_rad(randf_range(-359, 359))
			while FileAccess.file_exists("user://" + filename + ".mdemo"):
				index += 1
				filename = "data" + str(index)
			for folder in DirAccess.get_directories_at("res://maps"):
				for file in DirAccess.get_files_at("res://maps/" + folder):
					maps.append(folder + "/" + file.split(".")[0])
			for file in DirAccess.get_files_at("res://maps"):
				maps.append(file.split(".")[0])
			var randmap = randi_range(0,len(maps) - 1)
			map = maps[randmap]
			var randlen = randf_range(5,15)
			if type == 3 or type == 4: # Type 3s should last longer.
				randlen = randf_range(10,35)
			randomPos = Vector3(randi_range(-100,100),randi_range(-100,100),randi_range(-100,100))
			print("DEBUG stats:")
			print("Demo was made in Masonry Toolkit version ",MTK_Version)
			print("Demo was shot in ",map)
			print("Demo finished recording at ",Time.get_datetime_string_from_unix_time(Time.get_unix_time_from_system() + randlen))
			print("Demo is ",randlen," seconds long.")
			ChangeLevel("res://maps/" + map + ".tscn")
			await LevelChanged
			CMDLine("record " + filename)
			interloper_active = true
			if type == 4:
				cmd_print(" : Failed to connect to server!")
				cmd_print(" : Timeout reached (ERR. 33213)")
				cmd_print(" : Player input handed to requester")
			if type != 2:
				await get_tree().create_timer(randlen).timeout
			else:
				await get_tree().create_timer(randlen - 1.0).timeout
				if FPSC_Player.sessionPlayer != null:
					FPSC_Player.sessionPlayer.health = 0
				await get_tree().create_timer(1).timeout
			CMDLine("stop")
			ChangeLevel("res://instances/mainmenu.tscn")
			cmd_found = true
	if not cmd_found: # The dedicated maxplayers clause got wiped out by doing this, it's just a variable
		for setter in setters:
			if setter.has_method(cmda[0]):
				setter.call(cmda[0])
			elif setter.get(cmda[0]) != null:
				#setter.set(cmda[0],cmda[1])
				var varia = setter.get(cmda[0])
				if varia is String:
					setter.set(cmda[0],cmda[1])
				if varia is int:
					setter.set(cmda[0],int(cmda[1]))
				if varia is bool:
					setter.set(cmda[0],cmda[1] == "true" or cmda[1] == "1")
				if varia is float:
					setter.set(cmda[0],float(cmda[1]))
				if varia is Vector2:
					setter.set(cmda[0],Vector2(float(cmda[1]),float(cmda[2])))
				if varia is Vector3:
					setter.set(cmda[0],Vector3(float(cmda[1]),float(cmda[2]),float(cmda[3])))


func AddConCommand(cmd_name,cmd_function,cmd_helpmessage="TODO: Replace this help message"):
	registered_commands[cmd_name] = [cmd_function,cmd_helpmessage]

func _ready():
	FPSC_LocalizationSystem.FPSC_LoadLocalization("en_US")
	FPSC_LoadGameConfig()
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Parse commands
	AddConCommand("map",cmd_map,"Changes level.")
	AddConCommand("connect",cmd_connect,"Connects to a remote server")
	AddConCommand("record",cmd_record,"Records a demo")
	AddConCommand("stop",cmd_stop,"Stops recording if a demo is being recorded.")
	AddConCommand("playdemo",cmd_playdemo,"Plays back a demo if it exists.")
	AddConCommand("set_demo_framerate",cmd_setdemo_framerate,"Sets the demo record tick rate.")
	AddConCommand("set_freeroam",cmd_setdemo_freeroam,"Sets if the player can free-roam during a demo")
	AddConCommand("set_freelook",cmd_setdemo_freelook,"Sets if the player can look around while a demo is playing")
	AddConCommand("version",cmd_version,"Displays version information")
	AddConCommand("bsploader_mount",cmd_bsploader_mount,"Mounts a Source Engine game via BSPLoader.")
	AddConCommand("help",cmd_help,"Displays a help message.")
	AddConCommand("noclip",cmd_noclip,"Toggles noclip.")
	await get_tree().process_frame
	await get_tree().process_frame
	#ChangeLevel("res://instances/mainmenu.tscn")
	#await LevelChanged
	print("CMDLine init!")
	var args: String = " ".join(OS.get_cmdline_user_args())
	var argv: PackedStringArray = args.split("+")
	for command in argv:
		print("Command: " + command)
		CMDLine(command)

func ChangeLevel(target_path: String):
	target_scene_path = target_path
	is_loading = true
	if get_tree().current_scene != null:
		lastmapname = get_tree().current_scene.scene_file_path
	# 1. Instantiate and display the animated loading screen
	FPSC_LoadingScreen.visible = true
	FPSC_LoadingScreen.oldLevelImage = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	get_tree().unload_current_scene() # Yeah, we have to get rid of the old scene first.
	# 2. Request Godot to start loading the new scene on a background thread
	ResourceLoader.load_threaded_request(target_path)

var demo_timeline = []

var demo_frame_interval = 0.2

var demo_freeroam = false
var demo_freelook = false

var elapsed = 0.0

func savedemo():
	var f = FileAccess.open("user://" + demoname + ".mdemo",FileAccess.WRITE)
	var path = ""
	if get_tree().current_scene != null:
		path = get_tree().current_scene.scene_file_path
	else:
		path = lastmapname
	f.store_var({"version":MTK_Version,"map":path,"demo_frame_interval":demo_frame_interval,"demo_timeline":demo_timeline,"demo_record_time":Time.get_datetime_dict_from_system(true),"demo_length":Time.get_unix_time_from_system() - demo_starttime})
	f.close()
	interloper_active = false
var lastmapname = ""
var ctval = Vector2.ZERO
func _process(_delta):
	if demoname != "":
		if interloper_active and FPSC_Player.sessionPlayer != null:
			if type == 0:
				FPSC_Player.sessionPlayer.rotation_degrees.y = randi_range(-359,359)
				FPSC_Player.sessionPlayer.get_node("Camera3D").rotation_degrees.x = randi_range(-90,90)
				FPSC_Player.sessionPlayer.velocity = Vector3.ZERO
				FPSC_Player.sessionPlayer.position = randomPos
			if type == 1:
				FPSC_Player.sessionPlayer.rotation = randomInitialRotation
				FPSC_Player.sessionPlayer.get_node("Camera3D").rotation_degrees.x = randi_range(-90,90)
				FPSC_Player.sessionPlayer.velocity = Vector3.ZERO
				FPSC_Player.sessionPlayer.position = randomPos
			if type == 2:
				FPSC_Player.sessionPlayer.velocity = Vector3.ZERO
				FPSC_Player.sessionPlayer.position = randomPos
				FPSC_Player.sessionPlayer.rotation = randomInitialRotation
			if type == 3: # func FPSC_ApplyInputs(m_args):
				"""func FPSC_ApplyInputs(m_args):
	stored_jump = m_args[0]
	stored_movedir = m_args[1]
	rotation = m_args[2]"""
				FPSC_Player.sessionPlayer.FPSC_ApplyInputs([randi_range(0,50) == 0,ctval,randomInitialRotation])
		if elapsed < demo_frame_interval:
			elapsed += demo_frame_interval
		else:
			elapsed = 0.0
			if randi_range(0,25) == 3: ctval = Vector2(randi_range(-1,1),randi_range(-1,1))
			if randi_range(0,15) == 7 and type != 2 and type != 4:
				var t = create_tween()
				t.tween_property(self,"randomInitialRotation",randomInitialRotation + Vector3(0,deg_to_rad(randf_range(-359, 359)),0),randf_range(0.04,1))
			var frame = []
			for object in FPSC_MultiplayerFramework.cached_entities:
				if object == null or not is_instance_valid(object):
					FPSC_MultiplayerFramework.cached_entities.erase(object)
					continue
				if object.has_method("FPSC_GetMPState"):
					var state = object.FPSC_GetMPState()
					var pathy = str(object.get_path())
					frame.append({"FPSC_UpdateMPState":[state,pathy]}) # Godot format since I have no idea what the hell it wants from me
				elif object is RigidBody3D:
					var state = [object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
					var pathy = str(object.get_path())
					frame.append({"FPSC_UpdateRigidbody":[state,pathy]})
			demo_timeline.append(frame)
	if demo_data != {}:
		if current_frame < len(demo_data.demo_timeline):
			if elapsed < demo_frame_interval:
				elapsed += demo_frame_interval
			else:
				elapsed = 0.0
				for frame in demo_data.demo_timeline[current_frame]:
					var m_name = frame.keys()[0]
					var m_args = frame[frame.keys()[0]]
					var m_sender = 1 # ported MP code. it just needs to do this.
					if get_node_or_null(m_args[1]) == null: continue # Probably just hasn't spawned in yet.
					if m_name == "FPSC_UpdateMPState" and m_sender == 1:
						#print("Updating state for ",m_args[1])
						get_node(m_args[1]).FPSC_ApplyMPState(m_args[0])
					if m_name == "FPSC_UpdateRigidbody" and m_sender == 1:#[object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
						var object : RigidBody3D = get_node(m_args[1])
						object.position = m_args[0][0]
						object.rotation = m_args[0][1]
						object.scale = m_args[0][2]
						object.collision_mask = m_args[0][3]
						object.collision_layer = m_args[0][4]
						object.angular_velocity = m_args[0][5]
						object.linear_velocity = m_args[0][6]
				current_frame += 1
		else:
			demo_data = {}
			ChangeLevel("res://instances/mainmenu.tscn")
	if not is_loading:
		return
	if demoname != "":
		savedemo()
	demoname = ""
	demo_timeline = []
	# Array to hold the loading progress array data (0.0 to 1.0)
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Update progress bar via the loading screen instance
			pass
			if FPSC_LoadingScreen and progress.size() > 0:
				FPSC_LoadingScreen.currentLoadingValue = progress[0] * 100
				
		ResourceLoader.THREAD_LOAD_LOADED:
			# Scene is finished loading!
			is_loading = false
			change_to_loaded_scene()
			
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Error: Failed to load scene.")
			is_loading = false
			FPSC_LoadingScreen.visible = false

func change_to_loaded_scene():
	# Retrieve the loaded resource from memory
	var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
	
	# Swap scenes safely
	get_tree().change_scene_to_packed(new_scene)
	FPSC_LoadingScreen.visible = false
	await get_tree().process_frame
	LevelChanged.emit()
	# Clean up and delete the loading screen overlay

func drop_current_level():
	get_tree().unload_current_scene()
	await get_tree().process_frame
	LevelChanged.emit()

#static var skyabilities = {"Disable Skybox":FPSC_SkyboxCamera.CurrentCamera.ToggleMovement}

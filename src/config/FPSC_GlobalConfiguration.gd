extends Node
class_name FPSC_GlobalState

static var maps_listed = {
	"DYNAMO lighting system test":"res://maps/devtest/FPSC_Test.tscn",
	"Physics testing area":"res://maps/devtest/devtest2.tscn",
	"Aerial Testing Course":"res://maps/afc_ch1_intro.tscn",
	"Portal testing area":"res://maps/devtest/devtest_portals.tscn",
	"NPC testing area":"res://maps/devtest/devtest_pathfinder.tscn",
	"ATC zoo area":"res://maps/zoo_afc_elements.tscn"}

var target_scene_path: String
var is_loading: bool = false

@onready var setters = [FPSC_MultiplayerFramework]

signal LevelChanged()

var VPKH = VPKHandler.CFileAccess

var source_mount_path = ""

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
		if not entity.is_inside_tree(): add_child(entity)

func CMDLine(command:String):
	var cmda = command.split(" ")
	if cmda[0] == "map":
		print("Changing level to " + cmda[1])
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
	elif cmda[0] == "connect":
		FPSC_LevelManager.drop_current_level()
		FPSC_MultiplayerFramework.start_client(cmda[1])
	elif cmda[0] == "bsploader_mount":
		print("MTK WILL lock up while this is loading!")
		gameinfo_process(cmda[1],cmda[2])
	else: # The dedicated maxplayers clause got wiped out by doing this, it's just a variable
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
func _ready():
	FPSC_LocalizationSystem.FPSC_LoadLocalization("en_US")
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Parse commands
	await get_tree().process_frame
	await get_tree().process_frame
	print("CMDLine init!")
	var args: String = " ".join(OS.get_cmdline_user_args())
	var argv: PackedStringArray = args.split("+")
	for command in argv:
		print("Command: " + command)
		CMDLine(command)

func ChangeLevel(target_path: String):
	target_scene_path = target_path
	is_loading = true
	
	# 1. Instantiate and display the animated loading screen
	FPSC_LoadingScreen.visible = true
	FPSC_LoadingScreen.oldLevelImage = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	get_tree().unload_current_scene() # Yeah, we have to get rid of the old scene first.
	# 2. Request Godot to start loading the new scene on a background thread
	ResourceLoader.load_threaded_request(target_path)

func _process(_delta):
	if not is_loading:
		return
		
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

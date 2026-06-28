extends Node
class_name FPSC_GlobalState

static var maps_listed = {
	"DYNAMO lighting system test":"res://maps/devtest/FPSC_Test.tscn",
	"Physics testing area":"res://maps/devtest/devtest2.tscn",
	"Aerial Testing Course":"res://maps/afc_ch1_intro.tscn",
	"Portal testing area":"res://maps/devtest/devtest_portals.tscn",
	"Spotter testing area":"res://maps/devtest/devtest_os95_spotter_diff.tscn",
	"NPC testing area":"res://maps/devtest/devtest_pathfinder.tscn",
	"ATC zoo area":"res://maps/zoo_afc_elements.tscn"}

var target_scene_path: String
var is_loading: bool = false

@onready var setters = [FPSC_MultiplayerFramework]

signal LevelChanged()

func CMDLine(command:String):
	var cmda = command.split(" ")
	if cmda[0] == "map":
		print("Changing level to " + cmda[1])
		FPSC_LevelManager.ChangeLevel("res://maps/" + cmda[1] + ".tscn")
		if FPSC_MultiplayerFramework.maxplayers > 1: # We're trying to enroll as a server
			await FPSC_LevelManager.LevelChanged
			print("Full assurance that the game has started, the level has loaded, and we are ready to start listening.")
			FPSC_MultiplayerFramework.start_server()
	elif cmda[0] == "connect":
		FPSC_LevelManager.drop_current_level()
		FPSC_MultiplayerFramework.start_client(cmda[1])
	else: # The dedicated maxplayers clause got wiped out by doing this, it's just a variable
		for setter in setters:
			if setter.get(cmda[0]) != null:
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

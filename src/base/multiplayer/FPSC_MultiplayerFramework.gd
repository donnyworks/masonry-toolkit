extends Node
class_name FPSC_MultiplayerFrameworkInstance

var PORT = 22012

var maxplayers = 1

var sv_listen = true

var sv_comms_mode = Monolyth.TYPE_TCP

const MAXPLAYERS_MIN = 1
const MAXPLAYERS_MAX = 16

func recurse_me(node:Node):
	for object in node.get_children():
		# Scene and whatnot
		if object.has_method("FPSC_GetMPState"):
			if not object is FPSC_Weapon:
				var state = object.FPSC_GetMPState()
				var pathy = str(object.get_path())
				Monolyth.SendMessage("FPSC_UpdateMPState",[state,pathy],Monolyth.get_remote_sender_id()) # Godot format since I have no idea what the hell it wants from me
		elif object is RigidBody3D:
			var state = [object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
			var pathy = str(object.get_path())
			Monolyth.SendMessage("FPSC_UpdateRigidbody",[state,pathy],Monolyth.get_remote_sender_id())
		else:
			recurse_me(object)

var FPSC_ReadyForNewState = false

func SV_MessageHandler(m_name,m_args,m_sender):
	if m_name == "ConnectionReceived" and m_sender == -1:
		var id = m_args[0]
		var player = preload("res://instances/player.tscn").duplicate().instantiate()
		player.name = str(id)
		get_tree().current_scene.add_child(player)
		Monolyth.SendMessage("LoadLevel",[get_tree().current_scene.scene_file_path],id,"neutral")
	if m_name == "FPSC_PlayerList":
		var list = []
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				list.append(object.name) # Every player name is their ID, so this should just work
		Monolyth.SendMessage("FPSC_RecvPlayerList",list,Monolyth.get_remote_sender_id())
	if m_name == "FPSC_UpdatePlayState":
		get_tree().current_scene.get_node(str(m_sender)).FPSC_ApplyInputs(m_args)
	if m_name == "FPSC_ReadyForState":
		recurse_me(get_tree().current_scene)
		Monolyth.SendMessage("FPSC_StateExhausted",[],Monolyth.get_remote_sender_id())
	pass

func CL_MessageHandler(m_name,m_args,m_sender):
	if m_name == "LoadLevel" and m_sender == 1:
		var level = m_args[0]
		FPSC_LevelManager.ChangeLevel(level)
		await FPSC_LevelManager.LevelChanged
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player: # This deletes us.
				object.queue_free()
		FPSC_Player.sessionPlayer = null
		Monolyth.SendMessage("FPSC_PlayerList",[],1)
	if m_name == "FPSC_RecvPlayerList" and m_sender == 1:
		for id in m_args:
			var player = preload("res://instances/player.tscn").duplicate().instantiate()
			player.name = str(id)
			player.isSimulated = id != str(Monolyth.get_unique_id())
			get_tree().current_scene.add_child(player) # Ensures that _ready() is evaluated correctly
		Monolyth.SendMessage("FPSC_ReadyForState",[],1)
	if m_name == "FPSC_UpdateMPState" and m_sender == 1:
		print("Updating state for ",m_args[1])
		get_node(m_args[1]).FPSC_ApplyMPState(m_args[0])
	if m_name == "FPSC_StateExhausted" and m_sender == 1:
		await get_tree().process_frame # We literally wait a frame before we say we're ready.
		FPSC_ReadyForNewState = true
	if m_name == "FPSC_UpdateRigidbody" and m_sender == 1:#[object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
		var object : RigidBody3D = get_node(m_args[1])
		object.position = m_args[0][0]
		object.rotation = m_args[0][1]
		object.scale = m_args[0][2]
		object.collision_mask = m_args[0][3]
		object.collision_layer = m_args[0][4]
		object.angular_velocity = m_args[0][5]
		object.linear_velocity = m_args[0][6]
	if m_name == "ConnectionRemoved" and m_sender == -1:
		FPSC_LevelManager.ChangeLevel("res://maps/FPSC_Test.tscnds ")
		print("Disconnected from server: Server shutting down")
	pass
"""
		for object in get_tree().current_scene.get_children():
			# Scene and whatnot
			if object.has_method("FPSC_GetMPState"):
				var state = object.FPSC_GetMPState()
				var classy = object.get_class()
				var namey = object.name
				var pathy = object.get_path()
				Monolyth.SendMessage("FPSC_UpdateMPState",[state,classy,namey,pathy])"""
func start_server():
	if maxplayers < 2: return
	if maxplayers < MAXPLAYERS_MIN: maxplayers = MAXPLAYERS_MIN
	if maxplayers > MAXPLAYERS_MAX: maxplayers = MAXPLAYERS_MAX
	Monolyth.connect("OnMessage",SV_MessageHandler)
	Monolyth.start_server(PORT,maxplayers,sv_comms_mode)
	if sv_listen:
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				object.name = "1" # Reason: Players need to be named their ID so they're replicated properly
				object.isListenServer = true
	else:
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				object.currentWeapon.queue_free()
				FPSC_Player.sessionPlayer = null
				object.queue_free()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func start_client(ip:String):
	Monolyth.connect("OnMessage",CL_MessageHandler)
	if not ip.ends_with(":"):
		ip += ":" + str(PORT)
	Monolyth.start_client(ip,sv_comms_mode)

func _process(_delta):
	if FPSC_ReadyForNewState:
		print("ding! Requesting new state.")
		FPSC_ReadyForNewState = false
		Monolyth.SendMessage("FPSC_ReadyForState",[],1)

extends Node
class_name FPSC_MultiplayerFrameworkInstance

var PORT = 22012

var maxplayers = 1

var sv_listen = true

var sv_comms_mode = Monolyth.TYPE_TCP

const MAXPLAYERS_MIN = 1
const MAXPLAYERS_MAX = 16

var cached_entities = []

var cached_players = []

var connected_players = []

var ObjectOUIDs = {}

func _ready():
	FPSC_LevelManager.connect("LevelChanged",build_tree_up)
	#get_tree().connect("scene_changed",mp_changelevel)

func build_tree_up():
	if maxplayers == 1:
		print("Maxplayers is 1, cancelling build_tree_up!")
		return
	cached_entities = []
	cached_players = []
	print("build_tree_up -- maxplayers ",maxplayers)
	await get_tree().process_frame
	build_tree(get_tree().current_scene)
	if sv_listen:
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				object.name = "1" # Reason: Players need to be named their ID so they're replicated properly
				object.isListenServer = true
				cached_players.append(object)
	else:
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				object.currentWeapon.queue_free()
				FPSC_Player.sessionPlayer = null
				object.queue_free()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for id in connected_players:
		#var id = m_args[0]
		var player = preload("res://instances/player.tscn").duplicate().instantiate()
		player.name = str(id)
		#connected_players.append(id)
		cached_players.append(player) # add them to the scene
		get_tree().current_scene.add_child(player)

func recurse_me(_node:Node):
	var messages = []
	for object in cached_entities:
		if is_instance_valid(object):
			if not object is RigidBody3D:
				var state = object.FPSC_GetMPState()
				var pathy = str(GetOUIDForObject(object))
				messages.append([state,pathy,"MPState"])
				#Monolyth.SendMessage("FPSC_UpdateMPState",[state,pathy],Monolyth.get_remote_sender_id()) # Godot format since I have no idea what the hell it wants from me
			else:
				var state = [object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
				var pathy = str(GetOUIDForObject(object))
				#Monolyth.SendMessage("FPSC_UpdateRigidbody",[state,pathy],Monolyth.get_remote_sender_id())
				messages.append([state,pathy,"RigidBody"])
	for player in cached_players:
		if is_instance_valid(player):
			if player.name != "1":
				Monolyth.SendMessage("FPSC_StateUpdate",messages,int(player.name))
	pass

func build_tree(node:Node):
	for object in node.get_children():
		# Scene and whatnot
		if object.has_method("FPSC_GetMPState"):
			if not object is FPSC_Weapon:
				#print(str(object.get_path()).split("/",true,3))
				print("Multiplayer object found - ",object.name, " with OUID of ",str(object.get_path()).split("/",true,3)[3].hash())
				cached_entities.append(object)
				ObjectOUIDs[str(object.get_path()).split("/",true,3)[3].hash()] = object
				if not object.is_connected("tree_exiting", handle_node_deletion):
					object.connect("tree_exiting",handle_node_deletion)
		elif object is RigidBody3D:
			print("RigidBody object found - ",object.name)
			cached_entities.append(object)
			ObjectOUIDs[str(object.get_path()).split("/",true,3)[3].hash()] = object
			if not object.is_connected("tree_exiting", handle_node_deletion):
				object.connect("tree_exiting",handle_node_deletion)
		else:
			build_tree(object)

func handle_node_deletion(node:Node):
	Monolyth.SendMessage("FPSC_DeleteNode",[node.get_path()])
	cached_entities.erase(node)

var FPSC_ReadyForNewState = false

func SV_MessageHandler(m_name,m_args,m_sender):
	if m_name == "ConnectionReceived" and m_sender == -1:
		var id = m_args[0]
		var player = preload("res://instances/player.tscn").duplicate().instantiate()
		player.name = str(id)
		connected_players.append(id)
		cached_players.append(player) # add them to the scene
		get_tree().current_scene.add_child(player)
		print("Sending level ",get_tree().current_scene.scene_file_path)
		Monolyth.SendMessage("LoadLevel",[get_tree().current_scene.scene_file_path],id,"neutral")
	if m_name == "FPSC_PlayerList":
		var list = []
		for object in get_tree().current_scene.get_children():
			if object is FPSC_Player:
				list.append(object.name) # Every player name is their ID, so this should just work
		Monolyth.SendMessage("FPSC_RecvPlayerList",list,Monolyth.get_remote_sender_id())
	if m_name == "FPSC_UpdatePlayState":
		if get_tree().current_scene.get_node(str(m_sender)) == null: return
		get_tree().current_scene.get_node(str(m_sender)).FPSC_ApplyInputs(m_args)
		#for object in cached_players:
		#	var state = object.FPSC_GetMPState()
		#	var pathy = str(object.get_path())
		#	Monolyth.SendMessage("FPSC_UpdateMPState",[state,pathy],Monolyth.get_remote_sender_id()) # Godot format since I have no idea what the hell it wants from me
	if m_name == "FPSC_ReadyForState":
		recurse_me(get_tree().current_scene)
		#Monolyth.SendMessage("FPSC_StateExhausted",[],Monolyth.get_remote_sender_id())
	pass

func CL_MessageHandler(m_name,m_args,m_sender):
	if m_name == "LoadLevel" and m_sender == 1:
		var level = m_args[0]
		print("Loading level " + level)
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
	if m_name == "FPSC_StateUpdate" and m_sender == 1:
		print("Getting next state...")
		#Monolyth.SendMessage("FPSC_ReadyForState",[],1)
		#CL_MessageHandler("FPSC_StateExhausted",[],1)
		for message in m_args:
			if message[2] == "MPState":
				CL_MessageHandler("FPSC_UpdateMPState",message,1)
			if message[2] == "RigidBody":
				CL_MessageHandler("FPSC_UpdateRigidbody",message,1)
	if m_name == "FPSC_UpdateMPState" and m_sender == 1:
		#print("Updating state for ",m_args[1])
		if GetObjectFromOUID(m_args[1]) == null: return
		GetObjectFromOUID(m_args[1]).FPSC_ApplyMPState(m_args[0])
	if m_name == "FPSC_StateExhausted" and m_sender == 1:
		await get_tree().process_frame # We literally wait a frame before we say we're ready.
		FPSC_ReadyForNewState = true
	if m_name == "FPSC_DeleteNode" and m_sender == 1:
		if GetObjectFromOUID(m_args[0]) != null:
			GetObjectFromOUID(m_args[0]).queue_free() # yay! get it out of my house RIGHT NOW
	if m_name == "FPSC_UpdateRigidbody" and m_sender == 1:#[object.position,object.rotation,object.scale,object.collision_mask,object.collision_layer,object.angular_velocity,object.linear_velocity]
		if GetObjectFromOUID(m_args[1]) == null: return
		var object : RigidBody3D = GetObjectFromOUID(m_args[1])
		object.position = m_args[0][0]
		object.rotation = m_args[0][1]
		object.scale = m_args[0][2]
		object.collision_mask = m_args[0][3]
		object.collision_layer = m_args[0][4]
		object.angular_velocity = m_args[0][5]
		object.linear_velocity = m_args[0][6]
	if m_name == "ConnectionRemoved" and m_sender == -1:
		FPSC_LevelManager.ChangeLevel("res://maps/devtest/FPSC_Test.tscn")
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

func GetOUIDForObject(object:Node):
	# nodepath.split("/",3)[1].hash()?
	# we need a reversable process.
	# it's fragile, but so is every other implementation using the scenetree
	#print(object)
	#print(ObjectOUIDs)
	return ObjectOUIDs.find_key(object)

func GetObjectFromOUID(ids:String) -> Node:
	var id = int(ids)
	if not id in ObjectOUIDs.keys():
		return null
	return ObjectOUIDs[id]

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
				cached_players.append(object)
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
	if not Monolyth.isClient: # dangerous!
		recurse_me(get_tree().current_scene)

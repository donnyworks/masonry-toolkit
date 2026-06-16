extends Node
class_name MonolythNetworkSystem
## Monolyth Networking System - modified to neccessity for Masonry Toolkit

const TYPE_ENET := 0
const TYPE_WEBSOCKET := 1
const TYPE_TCP := 2

signal OnMessage(m_name:String,m_args:Array,m_sender:int)

static var CurrentSession = null
static var isMultiplayer = false
static var session_maxplayers = 0
static var current_player_count = 0
static var isClient = false
static var TCPModeServer : TCPServer = null
static var TCPModeClient : StreamPeerTCP = null
static var TCP_Clients = []

func start_server(port : int,maxplayers : int,type:=TYPE_ENET):
	session_maxplayers = maxplayers
	isMultiplayer = true
	var server = null
	if type == TYPE_ENET:
		server = ENetMultiplayerPeer.new()
		server.create_server(port,maxplayers)
		multiplayer.multiplayer_peer = server
		multiplayer.connect("peer_connected",player_join)
		multiplayer.connect("peer_disconnected",player_leave)
	if type == TYPE_WEBSOCKET:
		server = WebSocketMultiplayerPeer.new()
		server.create_server(port)
		multiplayer.multiplayer_peer = server
		multiplayer.connect("peer_connected",player_join)
		multiplayer.connect("peer_disconnected",player_leave)
	if type == TYPE_TCP:
		print("WARNING: TCP mode is in VERY early beta! It may just explode!")
		server = TCPServer.new()
		server.listen(port)
		TCPModeServer = server

func start_client(ip : String,type:=TYPE_ENET):
	var client = null
	if type == TYPE_ENET:
		client = ENetMultiplayerPeer.new()
		client.create_client(ip.split(":")[0],int(ip.split(":")[1]))
		multiplayer.multiplayer_peer = client
		multiplayer.connect("peer_connected",player_join)
		multiplayer.connect("peer_disconnected",player_leave)
	if type == TYPE_WEBSOCKET:
		client = WebSocketMultiplayerPeer.new()
		client.create_client(ip)
		multiplayer.multiplayer_peer = client
		multiplayer.connect("peer_connected",player_join)
		multiplayer.connect("peer_disconnected",player_leave)
	if type == TYPE_TCP:
		print("WARNING: TCP mode is in VERY early beta! It may just explode!")
		TCPModeClient = StreamPeerTCP.new()
		TCPModeClient.connect_to_host(ip.split(":")[0],int(ip.split(":")[1]))
	isMultiplayer = true
	isClient = true

func get_unique_id(): # Putting this here for cross-compatibility
	if TCPModeClient == null and TCPModeServer == null:
		return multiplayer.get_unique_id()
	else:
		return unique_id

func get_remote_sender_id():
	if TCPModeClient == null and TCPModeServer == null:
		return multiplayer.get_remote_sender_id()
	else:
		return latest_reciever_id

var latest_reciever_id = 0
var unique_id = 1
var clients = []
var streams_to_guids = {}
var clients_to_guids = {} # GUID stands for Godot User ID in this case because multiplayer.get_unique_id() go brr
var guids_to_streams = {} # We really shouldn't have or need this

func _process(_delta: float) -> void:
	for clientdst in clients:
		var client = clientdst.stream
		client.poll()
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if clientdst.complete:
				var b = client.get_available_bytes()
				if b > 0:
					var rd = client.get_string()
					#print(rd)
					var bytes = JSON.parse_string(rd) # We're sending data the Python way, baby!
					# TODO: Parse! Parse! Parse!
					# A struct could be {"name":name,"args":[],"recipient":1,"sender":2763}
					bytes.sender = int(bytes.sender)
					bytes.recipient = int(bytes.recipient)
					if bytes.mode == "godot":
						bytes.args = JSON.to_native(bytes.args)
					if bytes.recipient == -1 and bytes.sender != unique_id:
						if bytes.sender != -1: latest_reciever_id = bytes.sender
						#print("Wow! Message ",bytes.name," from ",bytes.sender)
						OnMessage.emit(bytes.name,bytes.args,bytes.sender)
					if bytes.recipient == unique_id:
						latest_reciever_id = bytes.sender
						#print("Wow! Message ",bytes.name," from ",bytes.sender)
						OnMessage.emit(bytes.name,bytes.args,bytes.sender)
					else:
						if unique_id == 1:
							for clientd2 in clients:
								clientd2.stream.poll()
								if clientd2.stream.get_status() == StreamPeerTCP.STATUS_CONNECTED:
									print("I am the server, and I approve of sending ",bytes.name," to ",streams_to_guids.find_key(clientd2.stream))
									clientd2.stream.put_string(rd)
			else:
				if TCPModeServer != null:
					print('Server: sending client their guid! (it\'s %s)' % streams_to_guids.find_key(client))
					client.put_string(str(streams_to_guids.find_key(client)))
					clientdst.complete = true
					OnMessage.emit("ConnectionReceived",[streams_to_guids.find_key(client)],-1)
					for clientd2 in clients:
						clientd2.stream.poll()
						if clientd2.stream.get_status() == StreamPeerTCP.STATUS_CONNECTED:
							if clientd2.complete:
								#print("Client's gotta believe!",JSON.stringify({"name":"ConnectionReceived","args":JSON.from_native([streams_to_guids.find_key(client)]),"sender":1,"recipient":-1,"mode":"godot"}))
								clientd2.stream.put_string(JSON.stringify({"name":"ConnectionReceived","args":JSON.from_native([streams_to_guids.find_key(client)]),"sender":-1,"recipient":-1,"mode":"godot"}))
		if client.get_status() == StreamPeerTCP.STATUS_NONE: # This means we've disconnected
			OnMessage.emit("ConnectionRemoved",[guids_to_streams[client]],-1)
	if TCPModeServer != null:
		ServerConnectionManager()
	if TCPModeClient != null:
		ClientConnectionManager()

func ServerConnectionManager():
	if TCPModeServer.is_connection_available() and TCPModeServer.is_listening():
		var stream = TCPModeServer.take_connection()
		stream.set_no_delay(true)
		clients.append({"stream":stream,"complete":false})
		var n = randi_range(93453345,99999999788)
		streams_to_guids[n] = stream
		clients_to_guids[n] = len(clients) - 1 # A pointer to an index into an array! Yay!
		guids_to_streams[stream] = n

func ClientConnectionManager():
	TCPModeClient.poll()
	if TCPModeClient.get_status() != TCPModeClient.STATUS_CONNECTED:
		return # Make sure that we wait to be connected
	if unique_id == 1:
		if TCPModeClient.get_available_bytes() > 0:
			unique_id = int(TCPModeClient.get_string())
			clients.append({"stream":TCPModeClient,"complete":true})
			clients_to_guids[1] = TCPModeClient
			streams_to_guids[1] = TCPModeClient
			guids_to_streams[TCPModeClient] = 1

func player_macro(): return "Playing as " + ("Client" if isClient else "Server") + " " # A one-liner designed to make it easier to debug Monolyth protocol apps.

func player_join(id):
	current_player_count += 1
	if current_player_count > session_maxplayers and not isClient:
		rpc_id(id,"GetMessage","TooManyPlayers",[])
	OnMessage.emit("ConnectionReceived",[id],-1)
	pass

func player_leave(id):
	current_player_count -= 1
	OnMessage.emit("ConnectionRemoved",[id],-1)
	pass

func _SendMessage_TCP(m_name,m_args,id,mode):
	if TCPModeClient != null:
		TCPModeClient.put_string(JSON.stringify({"name":m_name,"args":JSON.from_native(m_args) if mode == "godot" else m_args,"recipient":id,"sender":get_unique_id(),"mode":mode}))
	if TCPModeServer != null:
		if id != -1:
			streams_to_guids[id].put_string(JSON.stringify({"name":m_name,"args":JSON.from_native(m_args) if mode == "godot" else m_args,"recipient":id,"sender":get_unique_id(),"mode":mode}))
		else:
			for client in clients_to_guids:
				clients[clients_to_guids[client]].stream.put_string(JSON.stringify({"name":m_name,"args":JSON.from_native(m_args) if mode == "godot" else m_args,"recipient":client,"sender":get_unique_id(),"mode":mode}))
	

func SendMessage(m_name,m_args=[],id=-1,mode="godot"):
	if TCPModeClient != null or TCPModeServer != null:
		_SendMessage_TCP(m_name,m_args,id,mode)
		return
	if id == -1:
		rpc("GetMessage",m_name,m_args)
	else:
		rpc_id(id,"GetMessage",m_name,m_args)

@rpc("any_peer")
func GetMessage(m_name:String,m_args:Array):
	OnMessage.emit(m_name,m_args,multiplayer.get_remote_sender_id())

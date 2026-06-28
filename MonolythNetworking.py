# Python compatibility layer for Monolyth TCP mode.

# Bad practice to use _thread, or so it's said, but I put those claims to bed

# All you need to do is run DefineAcceptFunction(function), start a session, and the rest is taken care of for you!

import socket, _thread, json, random

session_socket = None

accept_functions = []

unique_id = 1
latest_reciever_id = 0
clients = []
streams_to_guids = {}
guids_to_streams = {} # This only exists to avoid lookup
clients_to_guids = {}

M_S_mode = 0

def get_unique_id():
    global unique_id
    return unique_id

def get_remote_sender_id():
    global latest_reciever_id
    return latest_reciever_id

def DefineAcceptFunction(func): # Equivalent of Monolyth.connect("OnMessage",func)
    global accept_functions
    accept_functions.append(func)

def GetStringFromStream(sock):
    length = int.from_bytes(sock.recv(4),"little") # Ignore length, it's zero-terminated
    return sock.recv(length).decode()

def parse_godot_types(data):
    # 1. Handle the "Flat List" Dictionary pattern
    if isinstance(data, list):
        # If it's a sequence of alternating key/value pairs
        # e.g., ["s:name", "s:value", "s:name2", "s:valiant2"]
        if len(data) % 2 == 0 and all(isinstance(x, str) and ":" in x for x in data[::2]):
            d = {}
            for i in range(0, len(data), 2):
                key = parse_godot_types(data[i])
                val = parse_godot_types(data[i+1])
                d[key] = val
            return d
        
        # Standard list processing for normal arrays
        return [parse_godot_types(item) for item in data]

    # 2. Handle Old-Style string prefixes (s:, v:, i:)
    if isinstance(data, str) and ":" in data:
        prefix, value = data.split(":", 1)
        if prefix == 's': return value
        if prefix == 'sn': return value
        if prefix == 'i': return int(value)
        if prefix == 'f': return float(value)
        if prefix == 'v': return [float(x) for x in value.split(",")]
        return value

    # 3. Handle Dictionary Blobs (New-Style)
    if isinstance(data, dict):
        if "type" in data:
            if data["type"] == "Vector2": return tuple(data["args"])
            if data["type"] == "Color": return tuple(data["args"])
            if data["type"] == "Dictionary": return parse_godot_types(data["args"])
        return {k: parse_godot_types(v) for k, v in data.items()}

    return data
def WriteStringToStream(sock,string):
    sock.send(len(string.encode("utf-8")).to_bytes(4,"little") + string.encode("utf-8"))

def SharedProcessor():
    global clients, streams_to_guids, clients_to_guids, unique_id, latest_reciever_id, accept_functions,M_S_mode
    while True:
        for clientdst in clients:
            client = clientdst["stream"]
            if clientdst["complete"]:
                rd = GetStringFromStream(client)
                bytes = json.loads(rd)
                bytes["sender"] = int(bytes["sender"])
                bytes["recipient"] = int(bytes["recipient"])
                if bytes["mode"] == "godot":
                    #print("TODO: Parse Godot datatypes")
                    #print("Using morally dubious Gemini code")
                    a = []
                    for value in bytes["args"]:
                        a.append(parse_godot_types(value))
                    bytes["args"] = a
                if bytes["recipient"] == -1 and bytes["sender"] != unique_id:
                    if bytes["sender"] != -1: latest_reciever_id = bytes["sender"]
                    #print("Wow! Message",bytes["name"])
                    for accept in accept_functions:
                        accept(bytes["name"],bytes["args"],bytes["sender"])
                if bytes["recipient"] == unique_id:
                    latest_reciever_id = bytes["sender"]
                    #print("Wow! Message",bytes["name"])
                    for accept in accept_functions:
                        accept(bytes["name"],bytes["args"],bytes["sender"])
                else:
                    if unique_id == 1:
                        for clientd2 in clients:
                            WriteStringToStream(clientd2["stream"],rd)
            else:
                if M_S_mode == 1:
                    WriteStringToStream(client,str(guids_to_streams[client]))
                    clientdst["complete"] = True
                    for accept in accept_functions:
                        accept("ConnectionReceived",[guids_to_streams[client]],-1)
                    for clientd2 in clients:
                        if clientd2["complete"]:
                            WriteStringToStream(clientd2["stream"],json.dumps({"name":"ConnectionReceived","args":["i:1"],"sender":-1,"recipient":-1,"mode":"godot"}))

def SendMessage(m_name,m_args=[],id=-1,mode="python"):
    global M_S_mode, session_socket, clients_to_guids, clients
    if M_S_mode != 0:
        #print("Sending approximately",JSON.stringify({"name":m_name,"args":JSON.from_native(m_args),"recipient":id,"sender":get_unique_id(),"mode":"godot"}))
        if M_S_mode == 2:
            WriteStringToStream(session_socket,json.dumps({"name":m_name,"args":m_args,"recipient":id,"sender":get_unique_id(),"mode":mode}))
        if M_S_mode == 1:
            if id != -1:
                WriteStringToStream(streams_to_guids[id],json.dumps({"name":m_name,"args":m_args,"recipient":id,"sender":get_unique_id(),"mode":mode}))
            else:
                for client in clients_to_guids:
                    WriteStringToStream(clients[clients_to_guids[client]]["stream"],json.dumps({"name":m_name,"args":m_args,"recipient":client,"sender":get_unique_id(),"mode":mode}))
    else:
        raise Exception("No networking instance exists to send messages across.")

def SVListenThread():
    global session_socket, clients, streams_to_guids, clients_to_guids, guids_to_streams
    s = session_socket
    while True:
        c, a = s.accept()
        print("Connection from",a)
        clients.append({"stream":c,"complete":False})
        n = random.randint(93453345,99999999788)
        streams_to_guids[n] = c
        guids_to_streams[c] = n
        clients_to_guids[n] = len(clients) - 1 # A pointer to an index into an array! Yay!

def CListenThread():
    global unique_id, session_socket, clients, clients_to_guids, streams_to_guids
    while True:
        if unique_id == 1:
            unique_id = int(GetStringFromStream(session_socket))
            clients.append({"stream":session_socket,"complete":True})
            clients_to_guids[1] = session_socket
            streams_to_guids[1] = session_socket

def start_server(port):
    global session_socket, M_S_mode
    M_S_mode = 1
    session_socket = socket.socket()
    s = session_socket
    s.bind(("0.0.0.0",port))
    s.listen(5)
    _thread.start_new_thread(SharedProcessor,tuple([]))
    _thread.start_new_thread(SVListenThread,tuple([]))

def start_client(ipandport):
    global session_socket, M_S_mode
    M_S_mode = 2
    session_socket = socket.socket()
    s = session_socket
    s.connect((ipandport.split(":")[0],int(ipandport.split(":")[1])))
    _thread.start_new_thread(SharedProcessor,tuple([]))
    _thread.start_new_thread(CListenThread,tuple([]))


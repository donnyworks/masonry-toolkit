from MonolythNetworking import *

PORT = 22011

players = []

playerstates = {}

level = "res://maps/afc_ch1_trust_fling.tscn"

scene_root = "/root/Node3D"

def PHF_None(sender,arguments):
    global playerstates
    playerstates[sender]["rotation"] = arguments[2]["args"]
    pass

def Array_to_GDCVec3(array):
    return {"args":array,"type":"Vector3"}

player_handler_function = PHF_None

def SV_Accept(m_name,m_args,sender):
    global players, scene_root
    if m_name == "ConnectionReceived":
        players.append(str(m_args[0]))
        playerstates[str(m_args[0])] = {"position":[0,0,0],"rotation":[0,0,0],"velocity":[0,0,0]}
        print("Player ID " + str(m_args[0]) + " joined the server.")
        SendMessage("LoadLevel",[level],m_args[0])
    if m_name == "FPSC_PlayerList":
        SendMessage("FPSC_RecvPlayerList",players)
    if m_name == "FPSC_UpdatePlayState":
        player_handler_function(str(sender),m_args)
    if m_name == "FPSC_ReadyForState":
        for player in players:
            state = playerstates[player]
            path = scene_root + "/" + player
            #SendMessage("FPSC_UpdateMPState",[[[state["velocity"],state["position"],state["rotation"],[]],path],sender)
        SendMessage("FPSC_StateExhausted",[],sender)
DefineAcceptFunction(SV_Accept)

start_server(PORT)

print("Started multiplayer for game 'Aerial Testing Course'")

print("Server running on map",level)

while True:
    pass

import socket, _thread
s = socket.socket()
s.bind(("0.0.0.0",2281))
s.listen(5)

maps = {}

running = True

def thread(): # This is the GMOD endpoint.
    global s, maps, running
    while running:
        c, a = s.accept()
        data = c.recv(1024).decode().split("\n")
        url = data[0].split(" ")[1].split("?")[0]
        query = data[0].split(" ")[1].split("?")[1].split("&")
        query_dict = {}
        for kv in query:
            query_dict[kv.split("=")[0]] = kv.split("=")[1]
        print(url)
        if url == "/favicon.ico":
            c.send(b"""HTTP/1.1 404 NOT FOUND\nContent-Type: text/plain\n\nno >:(""")
        else:
            if url == "/":
                c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\nhello world""")
            if url == "/join":
                if not "map" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                if query_dict["map"] in maps:
                    pass
                else:
                    maps[query_dict["map"]] = {"vessel":[],"player":[]}
                c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n0""")
            if url == "/addplayer":
                if not "map" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                if not "type" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                if not "name" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                maps[query_dict["map"]][query_dict["type"]].append({"name":query_dict["name"],"position":[0,0,0],"rotation":[0,0,0]})
                c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n""" + str(len(maps[query_dict["map"]][query_dict["type"]]) - 1).encode())
            if url == "/setplayer":
                if not "map" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                if not "type" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                if not "id" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                id = int(query_dict["id"])
                maps[query_dict["map"]][query_dict["type"]][id]["position"] = [float(query_dict["px"]),float(query_dict["py"]),float(query_dict["pz"])]
                maps[query_dict["map"]][query_dict["type"]][id]["rotation"] = [float(query_dict["rx"]),float(query_dict["ry"]),float(query_dict["rz"])]
                #maps[query_dict["map"]][query_dict["type"]].append({"name":query_dict["name"],"position":[0,0,0],"rotation":[0,0,0]})
                c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n0""")
            if url == "/getvessels":
                if not "map" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                response = """HTTP/1.1 200 OK\nContent-Type: text/plain\n\n"""
                for vessel in maps[query_dict["map"]]["vessel"]:
                    response += maps[query_dict["map"]]["vessel"][vessel]["name"] + "$$" + ArrayToString(maps[query_dict["map"]]["vessel"][vessel]["position"]) + "$$" + ArrayToString(maps[query_dict["map"]]["vessel"][vessel]["rotation"]) + "\n"
                c.send(response.encode())
            if url == "/getplayers":
                if not "map" in query_dict.keys():
                    c.send(b"""HTTP/1.1 200 OK\nContent-Type: text/plain\n\n-1""")
                    c.close()
                    continue
                response = """HTTP/1.1 200 OK\nContent-Type: text/plain\n\n"""
                for player in maps[query_dict["map"]]["player"]:
                    response += maps[query_dict["map"]]["player"][player]["name"] + "$$" + ArrayToString(maps[query_dict["map"]]["player"][player]["position"]) + "$$" + ArrayToString(maps[query_dict["map"]]["player"][player]["rotation"]) + "\n"
                c.send(response.encode())
        c.close()

for i in range(16): _thread.start_new_thread(thread,tuple([]))

try:
    while True:
        pass
except KeyboardInterrupt:
    running = False
    s.close()

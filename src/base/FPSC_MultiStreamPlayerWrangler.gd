extends Node
class_name FPSC_MultiStreamPlayerWrangler

@export var players : Array[AudioStreamPlayer3D]

var stream :
	set(v):
		for player in players:
			player.stream = v
		stream = v

var playing :
	set(v):
		for player in players:
			player.playing = v
		playing = v
	get():
		return players[0].playing

func play():
	for player in players:
		player.play()

func get_playback_position():
	return players[0].get_playback_position()

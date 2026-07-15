extends Node3D

var edict = {}
var player = preload("res://instances/player.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newplayer = player.instantiate()
	newplayer.position = position + Vector3(0,1,0)
	newplayer.scale = Vector3.ONE * 0.86253369272
	get_parent().add_child(newplayer)
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

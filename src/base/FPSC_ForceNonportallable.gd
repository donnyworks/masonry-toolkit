extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		child.add_to_group("Non-Portalable",true)
		for subchild in child.get_children(): # just to be safe
			subchild.add_to_group("Non-Portalable",true)
	pass # Replace with function body.

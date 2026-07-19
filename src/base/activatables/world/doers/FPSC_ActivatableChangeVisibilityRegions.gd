extends FPSC_Activatable
class_name FPSC_VisibilityChangeActivatable

@export var node_a : Node3D

@export var node_b : Node3D

func _ready():
	node_a.visible = true
	if node_b != null: node_b.visible = false

func on_enter(_body:Node3D):
	node_a.visible = false
	if node_b != null: node_b.visible = true

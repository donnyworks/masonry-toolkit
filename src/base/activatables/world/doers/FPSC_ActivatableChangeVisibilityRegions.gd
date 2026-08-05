extends FPSC_Activatable
class_name FPSC_VisibilityChangeActivatable

@export var node_a : Node3D

@export var node_b : Node3D

@export var toggle_back := false

func _ready():
	if node_a != null: node_a.visible = true
	if node_b != null: node_b.visible = false

func on_enter(_body:Node3D):
	if node_a != null: node_a.visible = false
	if node_b != null: node_b.visible = true

func on_exit(_body:Node3D):
	if not toggle_back: return
	if node_a != null: node_a.visible = true
	if node_b != null: node_b.visible = false

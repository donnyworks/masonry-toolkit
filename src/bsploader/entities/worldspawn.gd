extends StaticBody3D
var meshi = MeshInstance3D.new()
var coli = CollisionShape3D.new()
var model : ArrayMesh:
		set(v):
			meshi.mesh = v
			coli.shape = edict.collision_model
			#coli.shape = v.create_trimesh_shape()
			model = v
		get():
			return model
var edict = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(coli)
	add_child(meshi)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

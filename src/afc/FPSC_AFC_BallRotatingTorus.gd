extends CSGTorus3D

@export_enum("X:0","Y:1","Z:2") var AxisOfRotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if AxisOfRotation == 0:
		rotation.x += delta*10.0
	if AxisOfRotation == 1:
		rotation.y += delta*10.0
	if AxisOfRotation == 2:
		rotation.z += delta*10.0
	pass

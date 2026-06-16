extends CSGBox3D

@export var checkFlag : String = "use_collision"

var color_red = StandardMaterial3D.new()

var color_blue = StandardMaterial3D.new()

func _ready():
	color_red.albedo_color = Color(1,0,0)
	color_blue.albedo_color = Color(0,0,1)

func _process(_delta):
	if get(checkFlag):
		material = color_blue
	else:
		material = color_red

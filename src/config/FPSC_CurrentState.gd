extends Object
class_name FPSC_GameState

## When is this ever used? Half these variables were outdated by MultiplayerFramework. [Donovan 06/10/26]

static var isServer = false
static var isSingleplayer = true
static var maxplayers = 1
static var gravity_scale = 1.0
static var gravity_dir = Vector3(0,-9.8,0):
	set(v):
		gravity_dir = v
	get():
		return gravity_dir*gravity_scale

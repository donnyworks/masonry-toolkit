extends Control
class_name FPSC_LoadingScreenBase

var oldLevelImage : ImageTexture :
	set(v):
		get_node("PreviousLevel").texture = v
		oldLevelImage = v

var currentLoadingValue : float :
	set(v):
		get_node("ProgressBar").value = v
		currentLoadingValue = v

extends Control
class_name FPSC_BaseCaptionSystem

var lines = []

func FPSC_AddCaptionLine(line:String):
	if len(lines) < 2:
		$"1line".visible = true
		$"2line".visible = false
		$"1line/RichTextLabel".text += line + "\n"
		$"2line/RichTextLabel".text += line + "\n"
		$CaptionFadeTimer.start(2)
		lines.append(line)
	else:
		$"1line".visible = false
		$"2line".visible = true
		$"2line/RichTextLabel".text += line + "\n"
		$CaptionFadeTimer.start(2)
		lines.append(line)


func _on_caption_fade_timer_timeout() -> void:
	$"1line/RichTextLabel".text = ""
	$"2line/RichTextLabel".text = ""
	$"1line".visible = false
	$"2line".visible = false
	lines = []
	pass # Replace with function body.

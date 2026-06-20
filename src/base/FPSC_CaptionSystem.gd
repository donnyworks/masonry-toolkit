extends CanvasLayer
class_name FPSC_BaseCaptionSystem

var lines = []

func FPSC_AddCaptionLine(line:String,duration:float=2):
	if len(lines) < 2:
		$"1line".visible = true
		$"2line".visible = false
		$"1line/RichTextLabel".text += line + "\n"
		$"2line/RichTextLabel".text += line + "\n"
		$CaptionFadeTimer.start(duration)
		lines.append(line)
		await get_tree().create_timer(duration).timeout
		$"1line/RichTextLabel".text = $"1line/RichTextLabel".text.replace(line + "\n","")
		$"2line/RichTextLabel".text = $"2line/RichTextLabel".text.replace(line + "\n","")
	else:
		$"1line".visible = false
		$"2line".visible = true
		$"2line/RichTextLabel".text += line + "\n"
		$CaptionFadeTimer.start(duration)
		lines.append(line)
		await get_tree().create_timer(duration).timeout
		$"2line/RichTextLabel".text = $"2line/RichTextLabel".text.replace(line + "\n","")


func _on_caption_fade_timer_timeout() -> void:
	$"1line/RichTextLabel".text = ""
	$"2line/RichTextLabel".text = ""
	$"1line".visible = false
	$"2line".visible = false
	lines = []
	pass # Replace with function body.

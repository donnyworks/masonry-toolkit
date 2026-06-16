extends Node
class_name FPSC_LocalizationSystem

static var FPSC_LocalizationDB = {}

static func FPSC_LoadLocalization(language:String):
	FPSC_LocalizationDB = JSON.parse_string(FileAccess.get_file_as_string("res://resources/FPSC_lang_" + language + ".json"))

static func FPSC_GetLocalString(string:String):
	if not string in FPSC_LocalizationDB.keys():
		return string
	else:
		return FPSC_LocalizationDB[string]

extends Object
class_name VPKHandler

static var CFileAccess : CrossFileAccess

class StreamedBinaryData extends Object:
	var data : PackedByteArray
	var currentProgress : int
	func parse_from_bytes(bytes:PackedByteArray):
		data = bytes
	func get_signed8():
		var cdata = data.decode_s8(currentProgress)
		currentProgress += 1
		return cdata
	func get_unsigned8():
		var cdata = data.decode_u8(currentProgress)
		currentProgress += 1
		return cdata
	func get_signed16():
		var cdata = data.decode_s16(currentProgress)
		currentProgress += 2
		return cdata
	func get_unsigned16():
		var cdata = data.decode_u16(currentProgress)
		currentProgress += 2
		return cdata
	func get_signed32():
		var cdata = data.decode_s32(currentProgress)
		currentProgress += 4
		return cdata
	func get_unsigned32():
		var cdata = data.decode_u32(currentProgress)
		currentProgress += 4
		return cdata
	func get_float():
		var stream := StreamPeerBuffer.new()
		stream.data_array = data
		stream.seek(currentProgress)
		currentProgress += 4
		return stream.get_float()
		#var cdata = data.decode_float(currentProgress)
		#currentProgress += 4
		#return cdata
	func get_string_null_terminated():
		var cstr = ""
		while data[currentProgress] != 0:
			#print("Character ",data[currentProgress])
			cstr += char(data[currentProgress])
			currentProgress += 1
		currentProgress += 1
		return cstr
	func get_string_of_length(len:int):
		var cstr = ""
		for i in range(currentProgress,currentProgress + len):
			cstr += char(data[i])
		currentProgress += len
		return cstr
	func get_range_of_bytes(from:int,to:int):
		var data2 = PackedByteArray()
		currentProgress += from - currentProgress
		for i in range(from,to):
			data2.append(data[i])
		currentProgress += to - from
		return data2
	func jump_forward_to(spot:int):
		if spot < currentProgress:
			return "NO."
		else:
			currentProgress = spot
			return "YES."

class VPKTree extends StreamedBinaryData:
	var datastruct = {}
	var cached_vpks = {}
	func parse_from_file(file: VPKFile):
		parse_from_bytes(file.data)
		currentProgress = file.currentProgress
		while true:
			var extension = get_string_null_terminated()
			#print("Starting extension block ",extension)
			if extension == "": break
			while true:
				var path = get_string_null_terminated()
				#print("Starting path block ",path)
				if path == "": break
				if path == " ": path = ""
				if not path in datastruct.keys(): datastruct[path] = {}
				while true:
					var filename = get_string_null_terminated()
					#print("Starting filename ",filename)
					if filename == "": break
					var _crc = get_unsigned32()
					var preload_bytes = get_unsigned16()
					var archive_index = get_unsigned16()
					var entry_offset = get_unsigned32()
					var entry_length = get_unsigned32()
					get_unsigned16() # 0xFFFF
					#if path == "materials/console":
					#	print("Attempting to save " + path + "/" + filename + "." + extension)
					#	print("Current contents are ",datastruct[path].keys())
					if entry_length > 0:
						if archive_index == 0x7FFF: # Embedded
							datastruct[path][filename + "." + extension] = file.data.slice(file.HeaderSize+file.TreeSize+entry_offset,file.HeaderSize+file.TreeSize+entry_length)
						else:
							var istr = str(archive_index)
							if len(istr) < 3:
								for i in range(0,3 - len(istr)):
									istr = "0" + istr
							var newpath = file.archive_path.replace("_dir","_" + istr)
							if FileAccess.file_exists(newpath):
								if not newpath in cached_vpks.keys():
									cached_vpks[newpath] = FileAccess.get_file_as_bytes(newpath)
								datastruct[path][filename + "." + extension] = cached_vpks[newpath].slice(entry_offset,entry_offset+entry_length)
							else:
								print("VPK file ",newpath," is missing?")
					else:
						datastruct[path][filename + "." + extension] = file.get_range_of_bytes(file.currentProgress,file.currentProgress + preload_bytes)
class VPKFile extends StreamedBinaryData:
	var Signature : int; # const unsigned int
	var Version : int; # const unsigned int 
	var TreeSize : int; # unsigned int
	var FileDataSectionSize : int; # unsigned int
	var ArchiveMD5SectionSize : int; # unsigned int
	var OtherMD5SectionSize : int; # unsigned int
	var SignatureSectionSize : int; # unsigned int
	var HeaderSize = 12
	var VPKFileTree : VPKTree
	var archive_path : String
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		Signature = get_unsigned32()
		Version = get_unsigned32()
		TreeSize = get_unsigned32()
		print("VPK version ",Version)
		if Signature != 0x55aa1234:
			push_error("VPK signature is invalid!")
			return
		if Version > 2:
			push_error("Version",Version,"VPKs are not supported!")
			return
		if Version >= 2: # Futureproofed?
			FileDataSectionSize = get_unsigned32()
			ArchiveMD5SectionSize = get_unsigned32()
			OtherMD5SectionSize = get_unsigned32()
			SignatureSectionSize = get_unsigned32()
			HeaderSize += 16
		# Immediately after this is the dir tree
		VPKFileTree = VPKTree.new()
		VPKFileTree.parse_from_file(self)

class CrossFileAccess extends Object:
	var vpk_files : Array[VPKFileAccess] = []
	var source_path_root : String
	func _init(ssource_path_root:String):
		source_path_root = ssource_path_root
	func add_vpk_file(file:VPKFileAccess):
		vpk_files.append(file)
	func file_exists(path:String) -> bool:
		if FileAccess.file_exists(source_path_root + "/" + path):
			return true
		for vpk_file in vpk_files:
			#print("Checking path ",path," result ",vpk_file.file_exists(path))
			if vpk_file.file_exists(path):
				return true
		if FileAccess.file_exists(path):
			return true
		return false
	func get_file_as_bytes(path:String):
		if FileAccess.file_exists(source_path_root + "/" + path):
			return FileAccess.get_file_as_bytes(source_path_root + "/" + path)
		for vpk_file in vpk_files:
			#print("Checking path ",path," result ",vpk_file.file_exists(path))
			if vpk_file.file_exists(path):
				return vpk_file.get_file_as_bytes(path)
		if FileAccess.file_exists(path):
			return FileAccess.get_file_as_bytes(path)
		return ERR_FILE_NOT_FOUND
	func get_file_as_string(path:String):
		if FileAccess.file_exists(source_path_root + "/" + path):
			return FileAccess.get_file_as_string(source_path_root + "/" + path)
		for vpk_file in vpk_files:
			if vpk_file.file_exists(path):
				return vpk_file.get_file_as_string(path)
		if FileAccess.file_exists(path):
			return FileAccess.get_file_as_string(path)
		return ERR_FILE_NOT_FOUND

class VPKFileAccess extends Object:
	var file : VPKFile
	func _init(s_file:VPKFile) -> void:
		file = s_file
	func file_exists(path:String) -> bool:
		path = path.to_lower()
		var newpath = ""
		var p_array = path.split("/")
		for i in range(0,len(p_array) - 1):
			newpath += p_array[i] + "/"
		if len(newpath) < 1: return false
		newpath = newpath.erase(len(newpath) - 1)
		if newpath in file.VPKFileTree.datastruct.keys():
			if p_array[len(p_array) - 1] in file.VPKFileTree.datastruct[newpath].keys():
				return true
			else:
				return false
		else:
			return false
	func get_file_as_bytes(path:String):
		path = path.to_lower()
		var newpath = ""
		var p_array = path.split("/")
		for i in range(0,len(p_array) - 1):
			newpath += p_array[i] + "/"
		newpath = newpath.erase(len(newpath) - 1)
		if newpath in file.VPKFileTree.datastruct.keys():
			if p_array[len(p_array) - 1] in file.VPKFileTree.datastruct[newpath].keys():
				return file.VPKFileTree.datastruct[newpath][p_array[len(p_array) - 1]]
			else:
				return ERR_FILE_NOT_FOUND
		else:
			return ERR_FILE_NOT_FOUND
	func get_file_as_string(path:String):
		path = path.to_lower()
		var newpath = ""
		var p_array = path.split("/")
		for i in range(0,len(p_array) - 1):
			newpath += p_array[i] + "/"
		newpath = newpath.erase(len(newpath) - 1)
		if newpath in file.VPKFileTree.datastruct.keys():
			if p_array[len(p_array) - 1] in file.VPKFileTree.datastruct[newpath].keys():
				return file.VPKFileTree.datastruct[newpath][p_array[len(p_array) - 1]].get_string_from_utf8()
			else:
				return ERR_FILE_NOT_FOUND
		else:
			return ERR_FILE_NOT_FOUND

static func get_archive_from_path(path:String): # /home/loser/.steam/steam/steamapps/common/Half-Life 3/hl2/hl2_misc.vpk
	if path.ends_with("_dir.vpk"):
		push_error("VPK dir attempted to be loaded. Please just pass in what you would find in gameinfo.txt (hl2_misc.vpk, not hl2_misc_dir.vpk)")
	for i in range(0,999):
		var istr = str(i)
		if len(istr) < 3:
			for _n in range(0,3 - len(istr)):
				istr = "0" + istr
		if path.ends_with("_" + istr + ".vpk"):
			push_error("VPK data file attempted to be loaded. Please just pass in what you would find in gameinfo.txt (",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1].replace("_" + istr,""),", not ",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1],")")
	var n_path = path
	if not FileAccess.file_exists(path):
		if not FileAccess.file_exists(path.replace(".vpk","_dir.vpk")):
			push_error("VPK file does not exist!")
			return
		else:
			n_path = path.replace(".vpk","_dir.vpk")
	var v = VPKFile.new()
	v.archive_path = n_path
	v.parse_from_bytes(FileAccess.get_file_as_bytes(n_path))
	return v

static func get_fa_from_path(path:String): # /home/loser/.steam/steam/steamapps/common/Half-Life 3/hl2/hl2_misc.vpk
	if path.ends_with("_dir.vpk"):
		push_error("VPK dir attempted to be loaded. Please just pass in what you would find in gameinfo.txt (hl2_misc.vpk, not hl2_misc_dir.vpk)")
	for i in range(0,999):
		var istr = str(i)
		if len(istr) < 3:
			for _n in range(0,len(istr)):
				istr = "0" + istr
		if path.ends_with("_" + istr + ".vpk"):
			push_error("VPK data file attempted to be loaded. Please just pass in what you would find in gameinfo.txt (",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1].replace("_" + istr,""),", not ",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1],")")
	var n_path = path
	if not FileAccess.file_exists(path):
		if not FileAccess.file_exists(path.replace(".vpk","_dir.vpk")):
			push_error("VPK file does not exist!")
			return
		else:
			n_path = path.replace(".vpk","_dir.vpk")
	var v = VPKFile.new()
	v.archive_path = n_path
	v.parse_from_bytes(FileAccess.get_file_as_bytes(n_path))
	return VPKFileAccess.new(v)

static func setup_cfa_from_game_path(source_path:String): # /home/loser/.steam/steam/steamapps/common/Half-Life 3/hl2/hl2_misc.vpk
	CFileAccess = CrossFileAccess.new(source_path)

static func append_archive_to_cfa(path:String): # /home/loser/.steam/steam/steamapps/common/Half-Life 3/hl2/hl2_misc.vpk
	if path.ends_with("_dir.vpk"):
		push_error("VPK dir attempted to be loaded. Please just pass in what you would find in gameinfo.txt (hl2_misc.vpk, not hl2_misc_dir.vpk)")
	for i in range(0,999):
		var istr = str(i)
		if len(istr) < 3:
			for _n in range(0,len(istr)):
				istr = "0" + istr
		if path.ends_with("_" + istr + ".vpk"):
			push_error("VPK data file attempted to be loaded. Please just pass in what you would find in gameinfo.txt (",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1].replace("_" + istr,""),", not ",path.replace("\\","/").split("/")[len(path.replace("\\","/").split("/")) - 1],")")
	var n_path = path
	if not FileAccess.file_exists(path):
		if not FileAccess.file_exists(path.replace(".vpk","_dir.vpk")):
			push_error("VPK file does not exist!")
			return
		else:
			n_path = path.replace(".vpk","_dir.vpk")
	var v = VPKFile.new()
	v.archive_path = n_path
	v.parse_from_bytes(FileAccess.get_file_as_bytes(n_path))
	CFileAccess.add_vpk_file(VPKFileAccess.new(v))

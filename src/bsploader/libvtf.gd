extends Object
class_name VTFHandler

static var FA = FileAccess

enum ImageFormat
{
	IMAGE_FORMAT_UNKNOWN = -1,
	IMAGE_FORMAT_RGBA8888 = 0,
	IMAGE_FORMAT_ABGR8888,
	IMAGE_FORMAT_RGB888,
	IMAGE_FORMAT_BGR888,
	IMAGE_FORMAT_RGB565,
	IMAGE_FORMAT_I8,
	IMAGE_FORMAT_IA88,
	IMAGE_FORMAT_P8,
	IMAGE_FORMAT_A8,
	IMAGE_FORMAT_RGB888_BLUESCREEN,
	IMAGE_FORMAT_BGR888_BLUESCREEN,
	IMAGE_FORMAT_ARGB8888,
	IMAGE_FORMAT_BGRA8888,
	IMAGE_FORMAT_DXT1,
	IMAGE_FORMAT_DXT3,
	IMAGE_FORMAT_DXT5,
	IMAGE_FORMAT_BGRX8888,
	IMAGE_FORMAT_BGR565,
	IMAGE_FORMAT_BGRX5551,
	IMAGE_FORMAT_BGRA4444,
	IMAGE_FORMAT_DXT1_ONEBITALPHA,
	IMAGE_FORMAT_BGRA5551,
	IMAGE_FORMAT_UV88,
	IMAGE_FORMAT_UVWQ8888,
	IMAGE_FORMAT_RGBA16161616F,
	IMAGE_FORMAT_RGBA16161616,
	IMAGE_FORMAT_UVLX8888,
	IMAGE_FORMAT_R32F,
	IMAGE_FORMAT_RGB323232F,
	IMAGE_FORMAT_RGBA32323232F
};

enum CompiledVtfFlags
{
	TEXTUREFLAGS_POINTSAMPLE = 0x00000001,
	TEXTUREFLAGS_TRILINEAR = 0x00000002,
	TEXTUREFLAGS_CLAMPS = 0x00000004,
	TEXTUREFLAGS_CLAMPT = 0x00000008,
	TEXTUREFLAGS_ANISOTROPIC = 0x00000010,
	TEXTUREFLAGS_HINT_DXT5 = 0x00000020,
	TEXTUREFLAGS_PWL_CORRECTED = 0x00000040,
	TEXTUREFLAGS_NORMAL = 0x00000080,
	TEXTUREFLAGS_NOMIP = 0x00000100,
	TEXTUREFLAGS_NOLOD = 0x00000200,
	TEXTUREFLAGS_ALL_MIPS = 0x00000400,
	TEXTUREFLAGS_PROCEDURAL = 0x00000800,

	TEXTUREFLAGS_ONEBITALPHA = 0x00001000,
	TEXTUREFLAGS_EIGHTBITALPHA = 0x00002000,

	TEXTUREFLAGS_ENVMAP = 0x00004000,
	TEXTUREFLAGS_RENDERTARGET = 0x00008000,
	TEXTUREFLAGS_DEPTHRENDERTARGET = 0x00010000,
	TEXTUREFLAGS_NODEBUGOVERRIDE = 0x00020000,
	TEXTUREFLAGS_SINGLECOPY	= 0x00040000,
	TEXTUREFLAGS_PRE_SRGB = 0x00080000,
		
		TEXTUREFLAGS_UNUSED_00100000 = 0x00100000,
	TEXTUREFLAGS_UNUSED_00200000 = 0x00200000,
	TEXTUREFLAGS_UNUSED_00400000 = 0x00400000,

	TEXTUREFLAGS_NODEPTHBUFFER = 0x00800000,

	TEXTUREFLAGS_UNUSED_01000000 = 0x01000000,

	TEXTUREFLAGS_CLAMPU = 0x02000000,
	TEXTUREFLAGS_VERTEXTEXTURE = 0x04000000,
	TEXTUREFLAGS_SSBUMP = 0x08000000,

	TEXTUREFLAGS_UNUSED_10000000 = 0x10000000,

	TEXTUREFLAGS_BORDER = 0x20000000,

	TEXTUREFLAGS_UNUSED_40000000 = 0x40000000,
	TEXTUREFLAGS_UNUSED_80000000 = 0x80000000,
};

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

class VTFHeader extends StreamedBinaryData:
	var version : String # 7.2
	var headerSize : int # unsigned int
	var width : int # unsigned short
	var height : int # unsigned short
	var flags : int # unsigned int
	var frames : int # Amount of frames, unsigned short person
	var firstFrame : int # first frame, i won't give this short person my signature
	# 4 bytes of padding (get_unsigned32() to skip!)
	# var reflectivity : Array[float] = [0,0,0]
	# another 4 bytes of padding! Same technique.
	var bumpmapScale : float
	var highResImageFormat : int
	var mipmapCount : int # unsigned char
	var lowResImageFormat : int # int
	var lowResImageWidth : int # unsigned char
	var lowResImageHeight : int # unsigned char
	# all the other version-specific bullshit i can't be bothered to implement
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		# signature
		if get_unsigned32() != 0x00465456:
			print("VTF header invalid! ABORT, WE NEVER LEFT HIS SCH-")
			return
		version = str(get_unsigned32()) + "." + str(get_unsigned32())
		headerSize = get_unsigned32() # unsigned int
		width = get_unsigned16() # unsigned short
		height = get_unsigned16() # unsigned short
		flags = get_unsigned32() # unsigned int
		frames = get_unsigned16() # Amount of frames, unsigned short person
		firstFrame = get_unsigned16() # first frame, i won't give this short person my signature
		get_unsigned32()
		get_float()
		get_float()
		get_float()
		get_unsigned32()
		bumpmapScale = get_float()
		highResImageFormat = get_signed32()
		mipmapCount = get_unsigned8() # unsigned char
		lowResImageFormat = get_unsigned32() # int
		lowResImageWidth = get_unsigned8() # unsigned char
		lowResImageHeight = get_unsigned8() # unsigned char

class VTFFile extends StreamedBinaryData:
	var header := VTFHeader.new()
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		header.parse_from_bytes(bytes)
		jump_forward_to(header.headerSize)
		#print("VTF version " + header.version)
		#print()
	func get_image() -> Image:
		# 1. Skip the Low-Res Thumbnail
		var thumb_size = VTFHandler._get_format_size(header.lowResImageWidth, header.lowResImageHeight, header.lowResImageFormat)
		currentProgress += thumb_size
		
		# 2. Skip all smaller mipmaps to get to the largest one
		# VTF stores 1x1, 2x2, 4x4... up to FullRes
		# We iterate through mipmap levels (0 is the smallest)
		for i in range(header.mipmapCount - 1):
			var m_w = max(1, header.width >> (header.mipmapCount - 1 - i))
			var m_h = max(1, header.height >> (header.mipmapCount - 1 - i))
			
			# Sizes are multiplied by frames and faces (cubemaps have 6 faces + 1 sphere map)
			var face_count = 1
			if header.flags & CompiledVtfFlags.TEXTUREFLAGS_ENVMAP:
				face_count = 7 # 6 faces + 1 for the spheremap/padding
				
			var mip_size = VTFHandler._get_format_size(m_w, m_h, header.highResImageFormat) * header.frames * face_count
			currentProgress += mip_size

		# 3. Read the actual data for the largest mip
		var final_data_size = VTFHandler._get_format_size(header.width, header.height, header.highResImageFormat)
		#var raw_bytes = data.slice(currentProgress, currentProgress + final_data_size)
		var raw_bytes = get_range_of_bytes(currentProgress, currentProgress + final_data_size)
		# 4. Map to Godot Image Format
		var img = Image.create_from_data(header.width, header.height, false, VTFHandler._get_godot_format(header.highResImageFormat), raw_bytes)
		return img

static func _get_format_size(w: int, h:int, format:int) -> int:
	match format:
		ImageFormat.IMAGE_FORMAT_DXT1:
			return max(1, ((w + 3) / 4)) * max(1, ((h + 3) / 4)) * 8
		ImageFormat.IMAGE_FORMAT_DXT3, ImageFormat.IMAGE_FORMAT_DXT5:
			return max(1, ((w + 3) / 4)) * max(1, ((h + 3) / 4)) * 16
		ImageFormat.IMAGE_FORMAT_RGBA8888, ImageFormat.IMAGE_FORMAT_BGRA8888:
			return w * h * 4
		ImageFormat.IMAGE_FORMAT_RGB888, ImageFormat.IMAGE_FORMAT_BGR888:
			return w * h * 3
		_:
			return 0 # Handle others as needed

static func _get_godot_format(vtf_fmt: int) -> Image.Format:
	match vtf_fmt:
		ImageFormat.IMAGE_FORMAT_DXT1: return Image.FORMAT_DXT1
		ImageFormat.IMAGE_FORMAT_DXT5: return Image.FORMAT_DXT5
		ImageFormat.IMAGE_FORMAT_RGBA8888: return Image.FORMAT_RGBA8
		ImageFormat.IMAGE_FORMAT_RGB888: return Image.FORMAT_RGB8
		# Note: BGR formats will need a manual channel swap (R <-> B)
		_: return Image.FORMAT_L8

static func get_image_from_path(path:String):
	if FA.file_exists(path):
		var file = VTFFile.new()
		file.parse_from_bytes(FA.get_file_as_bytes(path))
		return file.get_image()
	else:
		return ERR_FILE_NOT_FOUND

static func get_header_from_path(path:String):
	if FA.file_exists(path):
		var file = VTFFile.new()
		file.parse_from_bytes(FA.get_file_as_bytes(path))
		return file.header
	else:
		return ERR_FILE_NOT_FOUND

static func get_texture_from_path(path:String):
	if FA.file_exists(path):
		var file = VTFFile.new()
		file.parse_from_bytes(FA.get_file_as_bytes(path))
		var it = ImageTexture.new()
		it.set_image(file.get_image())
		return it
	else:
		return ERR_FILE_NOT_FOUND

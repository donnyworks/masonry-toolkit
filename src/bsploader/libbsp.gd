extends Object
class_name BSPHandler

static var FA = FileAccess

static var bsp_version = 19 # This is changed by the most recently loaded BSP

const NON_BSP_FILE_INPUT = -64

enum BSPLumps{
	LUMP_ENTITIES,
	LUMP_PLANES,
	LUMP_TEXDATA,
	LUMP_VERTEXES,
	LUMP_VISIBILITY,
	LUMP_NODES,
	LUMP_TEXINFO,
	LUMP_FACES,
	LUMP_LIGHTING,
	LUMP_OCCLUSION,
	LUMP_LEAFS,
	LUMP_FACEIDS,
	LUMP_EDGES,
	LUMP_SURFEDGES,
	LUMP_MODELS,
	LUMP_WORLDLIGHTS,
	LUMP_LEAFFACES,
	LUMP_LEAFBRUSHES,
	LUMP_BRUSHES,
	LUMP_BRUSHSIDES,
	LUMP_AREAS,
	LUMP_AREAPORTALS,
	LUMP_PORTALS,
	LUMP_CLUSTERS,
	LUMP_PORTALVERTS,
	LUMP_CLUSTERPORTALS,
	LUMP_DISPINFO,
	LUMP_ORIGINALFACES,
	LUMP_PHYSDISP,
	LUMP_PHYSCOLLIDE,
	LUMP_VERTNORMALS,
	LUMP_VERTNORMALINDICIES,
	LUMP_DISP_LIGHTMAP_ALPHAS,
	LUMP_DISP_VERTS,
	LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS,
	LUMP_GAME_LUMP,
	LUMP_LEAFWATERDATA,
	LUMP_PRIMITIVES,
	LUMP_PRIMVERTS,
	LUMP_PRIMINDICIES,
	LUMP_PAKFILE,
	LUMP_CLIPPORTALVERTS,
	LUMP_CUBEMAPS,
	LUMP_TEXDATA_STRING_DATA,
	LUMP_TEXDATA_STRING_TABLE,
	LUMP_OVERLAYS,
	LUMP_LEAFMINDISTTOWATER,
	LUMP_FACE_MACRO_TEXTURE_INFO,
	LUMP_DISP_TRIS,
	LUMP_HPYSCOLLIDESURFACE,
	LUMP_WATEROVERLAYS
}

class BSPFile extends Object:
	var data : PackedByteArray
	var header : BSPHeader = BSPHeader.new()
	var currentProgress : int = 0
	var lumps_raw : Array[PackedByteArray] = []
	var lumps : Array[BSPLump]
	var material_cache = {}
	var source_game_path = "./source"
	func load_bsp_from_bytes(bytes:PackedByteArray):
		data = bytes
		if char(data[0]) != "V":
			return NON_BSP_FILE_INPUT
		if char(data[1]) != "B":
			return NON_BSP_FILE_INPUT
		if char(data[2]) != "S":
			return NON_BSP_FILE_INPUT
		if char(data[3]) != "P":
			return NON_BSP_FILE_INPUT
		header.parse_from_BSPFile(self)
		print("Current progress: ",currentProgress)
		for i in range(0,64):
			#print("Processing lump ", i)
			#print("[Lump ",i," extends from ",header.lumps[i].offset," to ",header.lumps[i].offset + header.lumps[i].length, "]")
			lumps_raw.append(
				get_range_of_bytes(
					header.lumps[i].offset, 
					header.lumps[i].offset + header.lumps[i].length)
				)
			append_lump_by_id(i)
	func get_unsigned32():
		var cdata = data.decode_u32(currentProgress)
		currentProgress += 4
		return cdata
	func get_float():
		var cdata = data.decode_float(currentProgress)
		currentProgress += 4
		return cdata
	func get_string_of_length(len:int):
		var cstr = ""
		for i in range(currentProgress,currentProgress + len):
			cstr += char(data[i])
		currentProgress += len
		return cstr
	func get_range_of_bytes(from:int,to:int):
		var data2 = PackedByteArray()
		if from - currentProgress > 0: currentProgress += from - currentProgress
		for i in range(from,to):
			data2.append(data[i])
		currentProgress += to - from
		return data2
	func append_lump_by_id(id:int):
		match id:
			0:
				var lmp = BSPLumpEntities.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_ENTITIES")
			1:
				var lmp = BSPLumpPlanes.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_PLANES")
			2: 
				var lmp = BSPLumpTextureData.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_TEXDATA")
			3:
				var lmp = BSPLumpVerticies.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_VERTEXES")
			4: 
				var lmp = BSPLump.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_VISIBILITY")
			5:
				var lmp = BSPLumpNodes.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_NODES")
			6: 
				var lmp = BSPLumpTextureInfo.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_TEXINFO")
			7:
				var lmp = BSPLumpFaces.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_FACES")
			8: 
				var lmp = BSPLump.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_LIGHTING")
			9: 
				var lmp = BSPLump.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_OCCLUSION")
			10: 
				var lmp = BSPLumpLeafs.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_LEAFS")
			11: 
				var lmp = BSPLump.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("(Source 2007/2009) LUMP_FACEIDS")
			12:
				var lmp = BSPLumpEdges.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_EDGES")
			13:
				var lmp = BSPLumpSurfaceEdges.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_SURFEDGES")
			14:
				var lmp = BSPLumpModels.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_MODELS")
			15: lumps.append(null)
			16: 
				var lmp = BSPLumpLeafFaces.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_LEAFFACES")
			17: 
				var lmp = BSPLumpLeafBrushes.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_LEAFBRUSHES")
			18: 
				var lmp = BSPLumpBrushes.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_BRUSHES")
			19: 
				var lmp = BSPLumpBrushSides.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lmp.generate_brushsides(header.version)
				lumps.append(lmp)
				print("LUMP_BRUSHSIDES")
			20: lumps.append(null)
			21: lumps.append(null)
			22: lumps.append(null)
			23: lumps.append(null)
			24: lumps.append(null)
			25: lumps.append(null)
			26: lumps.append(null)
			27: lumps.append(null)
			28: lumps.append(null)
			29: lumps.append(null)
			30: lumps.append(null)
			31: lumps.append(null)
			32: lumps.append(null)
			33: lumps.append(null)
			34: lumps.append(null)
			35: lumps.append(null)
			36: lumps.append(null)
			37: lumps.append(null)
			38: lumps.append(null)
			39: lumps.append(null)
			40: lumps.append(null)
			41: lumps.append(null)
			42: lumps.append(null)
			43:
				var lmp = BSPLumpTexStringLookup.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_TEXDATA_STRING_DATA")
			44:
				var lmp = BSPLumpTexStringLookup.new()
				lmp.parse_from_bytes(lumps_raw[id])
				lumps.append(lmp)
				print("LUMP_TEXDATA_STRING_TABLE")

class BSPEdge extends Object:
	var v1 : int
	var v2 : int
	func parse_from_bspedges(edges:BSPLumpEdges):
		v1 = edges.get_signed16()
		v2 = edges.get_signed16()

class BSPLumpEntry extends Object:
	var offset : int # int fileofs
	var length : int # int filelen
	var version : int # int version
	var code : int # char fourCC[4]
	func readEntryFromBSPFile(file:BSPFile):
		offset = file.get_unsigned32()
		length = file.get_unsigned32()
		version = file.get_unsigned32()
		code = file.get_unsigned32()

class BSPLump extends Object:
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

class BSPFace extends Object:
	var planenum : int # unsigned short
	var side : int # byte
	var onNode : int # byte
	var firstedge : int # int
	var numedges : int # short
	var texinfo : int # short
	var dispinfo : int # short
	var surfaceFogVolumeID : int # short person lmao
	var styles : Array[int] = [0,0,0,0] # byte[4]
	var lightofs : int # int
	var area : float # float
	var LightmapTextureMinsInLuxels : Array[int] = [0,0] # int[2]
	var LightmapTextureSizeInLuxels : Array[int] = [0,0] # int[2]
	var origFace : int # int
	var numPrims : int # unsigned short
	var firstPrimID : int # unsigned short
	var smoothingGroups : int # unsigned int
	func parse_from_lump(lump:BSPLumpFaces):
		planenum = lump.get_unsigned16()
		side = lump.get_signed8()
		onNode = lump.get_signed8()
		firstedge = lump.get_signed32()
		numedges = lump.get_signed16()
		texinfo = lump.get_signed16()
		dispinfo = lump.get_signed16()
		surfaceFogVolumeID = lump.get_signed16()
		styles[0] = lump.get_signed8()
		styles[1] = lump.get_signed8()
		styles[2] = lump.get_signed8()
		styles[3] = lump.get_signed8()
		lightofs = lump.get_signed32()
		area = lump.get_float()
		LightmapTextureMinsInLuxels[0] = lump.get_signed32()
		LightmapTextureMinsInLuxels[1] = lump.get_signed32()
		LightmapTextureSizeInLuxels[0] = lump.get_signed32()
		LightmapTextureSizeInLuxels[1] = lump.get_signed32()
		origFace = lump.get_signed32()
		numPrims = lump.get_unsigned16()
		firstPrimID = lump.get_unsigned16()
		smoothingGroups = lump.get_unsigned32()
		pass

class BSPModel extends Object:
	var mins : Vector3
	var maxs : Vector3
	var origin : Vector3
	var headnode : int
	var firstface : int
	var numfaces : int
	func parse_from_lump(lump:BSPLumpModels):
		mins = Vector3(lump.get_float(),lump.get_float(),lump.get_float())
		maxs = Vector3(lump.get_float(),lump.get_float(),lump.get_float())
		origin = Vector3(lump.get_float(),lump.get_float(),lump.get_float())
		headnode = lump.get_signed32()
		firstface = lump.get_signed32()
		numfaces = lump.get_signed32()

class BSPTextureInfo extends Object:
	var textureVecs : Array # float[2][4]
	var lightmapVecs : Array # float[2][4]
	var flags : int
	var texdata : int
	func parse_from_lump(lump:BSPLumpTextureInfo):
		textureVecs = [[
			lump.get_float(),
			lump.get_float(),
			lump.get_float(),
			lump.get_float()
		],[
			lump.get_float(),
			lump.get_float(),
			lump.get_float(),
			lump.get_float()
		]]
		lightmapVecs = [[
			lump.get_float(),
			lump.get_float(),
			lump.get_float(),
			lump.get_float()
		],[
			lump.get_float(),
			lump.get_float(),
			lump.get_float(),
			lump.get_float()
		]]
		flags = lump.get_signed32()
		texdata = lump.get_signed32()

class BSPTextureData extends Object:
	var reflectivity : Color
	var nameStringTableID : int
	var width : int
	var height : int
	var view_width : int
	var view_height : int
	func parse_from_lump(lump:BSPLumpTextureData):
		reflectivity.r = lump.get_float()
		reflectivity.g = lump.get_float()
		reflectivity.b = lump.get_float()
		nameStringTableID = lump.get_signed32()
		width = lump.get_signed32()
		height = lump.get_signed32()
		view_width = lump.get_signed32()
		view_height = lump.get_signed32()

class BSPLumpPlanes extends BSPLump:
	var planes : Array[Plane]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/20)):
			var plane = Plane()
			plane.x = get_float()
			plane.z = get_float()
			plane.y = -get_float()
			plane.d = get_float()
			get_unsigned32()
			planes.append(plane)

class BSPLumpVerticies extends BSPLump:
	var verts : Array[Vector3]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/12)):
			var x = get_float()
			var y = get_float()
			var z = get_float()
			var cve = Vector3(-x,z,y)
			verts.append(cve)
			#planes.append(plane)

class BSPLumpTemplate extends BSPLump:
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)

class BSPLumpFaces extends BSPLump:
	var faces : Array[BSPFace]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/56)):
			var face = BSPFace.new()
			face.parse_from_lump(self)
			faces.append(face)
	func get_verticies_for_id(file:BSPFile, id:int):
		var face : BSPFace = faces[id]
		var verticies : Array[Vector3]
		for i in range(face.firstedge,face.firstedge + face.numedges):
			var surfedge = file.lumps[BSPLumps.LUMP_SURFEDGES].surfedges[i]
			var v2first = surfedge < 0
			surfedge = abs(surfedge)
			var cedge : BSPEdge = file.lumps[BSPLumps.LUMP_EDGES].bspedges[surfedge]
			var verticies_c : Array[Vector3] = file.lumps[BSPLumps.LUMP_VERTEXES].verts
			if cedge.v1 > len(verticies_c) - 1 or cedge.v2 > len(verticies_c) - 1:
				print("Invalid edge ",cedge)
				continue
			if v2first:
				verticies.append(verticies_c[cedge.v2])
				#verticies.append(verticies_c[cedge.v1])
			else:
				verticies.append(verticies_c[cedge.v1])
				#verticies.append(verticies_c[cedge.v2])
		return verticies
	func get_all_verticies(file:BSPFile):
		var vertarrays = []
		for i in range(0,len(faces)):
			vertarrays.append(get_verticies_for_id(file,i))
		return vertarrays

class BSPLumpEdges extends BSPLump:
	var bspedges : Array[BSPEdge]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/4)):
			var edge = BSPEdge.new()
			edge.parse_from_bspedges(self)
			bspedges.append(edge)

class BSPLumpSurfaceEdges extends BSPLump:
	var surfedges : Array[int]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/4)):
			surfedges.append(get_signed32())

class BSPLumpModels extends BSPLump:
	var models : Array[BSPModel]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/48)):
			var m = BSPModel.new()
			m.parse_from_lump(self)
			models.append(m)
	func get_list_of_faces_by_id(file:BSPFile,id:int) -> Array[BSPFace]:
		var facelmp : BSPLumpFaces = file.lumps[BSPLumps.LUMP_FACES]
		var faces : Array[BSPFace]
		for i in range(models[id].firstface,models[id].firstface + models[id].numfaces):
			faces.append(facelmp.faces[i])
		return faces
	func get_list_of_face_indicies_by_id(file:BSPFile,id:int) -> Array[int]:
		var faces : Array[int]
		for i in range(models[id].firstface,models[id].firstface + models[id].numfaces):
			faces.append(i)
		return faces
	func get_verticies_by_id(file:BSPFile,id:int) -> Array:
		var vertarrays = []
		for i in range(models[id].firstface,models[id].firstface + models[id].numfaces):
			vertarrays.append(file.lumps[BSPLumps.LUMP_FACES].get_verticies_for_id(file,i))
		return vertarrays

class BSPLumpEntities extends BSPLump:
	var entities = []
	var datastring = ""
	var entities_raw = []
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		# in this case that doesn't matter because we're parsing the whole damn thing as a string
		datastring = bytes.get_string_from_ascii()
		entities_raw = datastring.replace("}","").split("{")
		var file = FileAccess.open("res://BSP_LMP_0.lmp",FileAccess.WRITE)
		file.store_string(datastring)
		file.close()
		for entity_def in entities_raw:
			#print(entity_def)
			if entity_def != "":
				var ent = {}
				print("--- ENTITY ---")
				for line in entity_def.replace("\n\"","$$ENDLINE").replace("\" \"","$$SEPERATOR").replace("\"\n","$$ENDLINE").replace("\"","").split("$$ENDLINE"):
					if line != "" and len(line.split("$$SEPERATOR")) > 1:
						var k = line.split("$$SEPERATOR")[0]
						var v = line.split("$$SEPERATOR")[1]
						#print(k,": ",v)
						if not k.begins_with("On"):
							ent[k] = v
						else: # that's an event
							if k in ent:
								ent[k].append(v)
							else:
								ent[k] = [v]
						if k == "origin":
							ent[k] = Vector3(-int(v.split(" ")[0]),int(v.split(" ")[2]),int(v.split(" ")[1]))
						if k == "angles":
							ent[k] = Vector3(int(v.split(" ")[0]),int(v.split(" ")[1]),int(v.split(" ")[2]))
				entities.append(ent)

class BSPLumpTextureInfo extends BSPLump:
	var textures : Array[BSPTextureInfo]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/72)):
			var tex = BSPTextureInfo.new()
			tex.parse_from_lump(self)
			textures.append(tex)

class BSPLumpTextureData extends BSPLump:
	var textures : Array[BSPTextureData]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/32)):
			var tex = BSPTextureData.new()
			tex.parse_from_lump(self)
			textures.append(tex)

class BSPLumpTexStringTable extends BSPLump: pass

class BSPLumpTexStringLookup extends BSPLump:
	var textures : Array[int]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/4)):
			textures.append(get_signed32())
	func lookup_from_id(file:BSPFile,id:int):
		var t_id = textures[id]
		var cbyte = file.lumps[BSPLumps.LUMP_TEXDATA_STRING_DATA].data[t_id]
		var cstr = ""
		while cbyte != 0:
			cstr += char(cbyte)
			t_id += 1
			cbyte = file.lumps[BSPLumps.LUMP_TEXDATA_STRING_DATA].data[t_id]
		return cstr

class BSPBrush extends Object:
	var firstside : int
	var numsides : int
	var contents : int
	func parse_from_lump(lump:BSPLumpBrushes):
		firstside = lump.get_signed32()
		numsides = lump.get_signed32()
		contents = lump.get_signed32()
		pass

class BSPLumpBrushes extends BSPLump:
	var brushes : Array[BSPBrush]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/12)):
			var brush = BSPBrush.new()
			brush.parse_from_lump(self)
			brushes.append(brush)

class BSPBrushSide extends Object:
	var planenum : int # unsigned short
	var texinfo : int # short
	var dispinfo : int # short
	var bevel : int # unsigned char / short
	var thin : int # unsigned char / null
	func parse_from_lump(lump:BSPLumpBrushSides, version:int):
		planenum = lump.get_unsigned16() # 2
		texinfo = lump.get_signed16() # 4
		dispinfo = lump.get_signed16() # 6
		if version >= 21:
			bevel = lump.get_unsigned8() # 7
			thin = lump.get_unsigned8() # 8
		else:
			bevel = lump.get_signed16()
		pass

class BSPLumpBrushSides extends BSPLump:
	var brush_sides : Array[BSPBrushSide]
	func generate_brushsides(version:int):
		for i in range(0,round(len(data)/8)):
			var brush = BSPBrushSide.new()
			brush.parse_from_lump(self, version)
			brush_sides.append(brush)

class BSPNode extends Object:
	var planenum : int
	var children : Array[int] = [0,0]
	var mins : Array[int] = [0,0,0] # short
	var maxs : Array[int] = [0,0,0] # short
	var firstface : int # unsigned short
	var numfaces : int # unsigned short
	var area : int # short
	var padding : int # short
	func parse_from_lump(lump:BSPLumpNodes):
		planenum = lump.get_signed32()
		children[0] = lump.get_signed32()
		children[1] = lump.get_signed32()
		mins[0] = lump.get_signed16()
		mins[1] = lump.get_signed16()
		mins[2] = lump.get_signed16()
		maxs[0] = lump.get_signed16()
		maxs[1] = lump.get_signed16()
		maxs[2] = lump.get_signed16()
		firstface = lump.get_unsigned16()
		numfaces = lump.get_unsigned16()
		area = lump.get_signed16()
		padding = lump.get_signed16()

class BSPLumpNodes extends BSPLump:
	var nodes : Array[BSPNode]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/32)):
			var node = BSPNode.new()
			node.parse_from_lump(self)
			nodes.append(node)

class BSPLeaf extends Object:
	var contents : int
	var cluster : int # short
	var area : int # short:9
	var flags : int # short:7
	var mins : Array[int] = [0,0,0]
	var maxs : Array[int] = [0,0,0]
	var firstleafface : int # unsigned short
	var numleaffaces : int # unsigned short
	var firstleafbrush : int # unsigned short
	var numleafbrushes : int # unsigned short
	var leafWaterDataID : int # short
	func parse_from_lump(lump: BSPLumpLeafs):
		# Skip contents (4) and cluster (2)
		contents = lump.get_signed32()
		cluster = lump.get_signed16()
		#lump.currentProgress += 6 

		# Replace the combined read with this:
		var area_raw = lump.get_unsigned16()
		area = area_raw & 0x01FF # Extract the 9 bits

		var flags_raw = lump.get_unsigned16()
		flags = flags_raw >> 9   # Extract the 7 bits

		# Now your stream cursor is perfectly aligned at the start of the 'mins' array!
		mins = [lump.get_signed16(), lump.get_signed16(), lump.get_signed16()]
		maxs = [lump.get_signed16(), lump.get_signed16(), lump.get_signed16()]
		
		# Read the combined Area/Flags short (2 bytes)
		#var combined = lump.get_unsigned16()
		#area = combined & 511          # Get the lower 9 bits
		#flags = combined >> 9          # Shift right to get the upper 7 bits

		# Continue reading the rest of the 32-byte struct
		#mins = [lump.get_signed16(), lump.get_signed16(), lump.get_signed16()]
		#maxs = [lump.get_signed16(), lump.get_signed16(), lump.get_signed16()]

		firstleafface = lump.get_unsigned16()
		numleaffaces = lump.get_unsigned16()

		# THESE ARE THE ONES YOU NEED FOR THE DOORS:
		firstleafbrush = lump.get_unsigned16()
		numleafbrushes = lump.get_unsigned16()

		# Skip leafWaterDataID (2) and padding (2)
		if BSPHandler.bsp_version >= 20:
			lump.currentProgress += 4 + 24
		else:
			lump.currentProgress += 2

class BSPLumpLeafs extends BSPLump:
	var leafs : Array[BSPLeaf]
	var struct_size = 32
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/32)):
			self.currentProgress = i * struct_size
			var leaf = BSPLeaf.new()
			leaf.parse_from_lump(self)
			leafs.append(leaf)
		# Add this temporary debug print right after your leaf parsing loop finishes
		for idx in range(clamp(leafs.size(), 0, 5)):
			var l = leafs[idx]
			print("Leaf %d -> contents: %d, firstbrush: %d, numbrushes: %d" % [idx, l.contents, l.firstleafbrush, l.numleafbrushes])
		#var total_bytes = len(bytes)
		#print("Total Leaf Lump Bytes: ", total_bytes)
		#print("If 32 bytes per leaf: ", total_bytes / 32.0)
		#print("If 30 bytes per leaf: ", total_bytes / 30.0)
		#print("If 56 bytes per leaf: ", total_bytes / 56.0)
		
class BSPLumpLeafFaces extends BSPLump:
	var leaf_faces : Array[int] # unsigned short[]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/2)):
			leaf_faces.append(get_unsigned16())

class BSPLumpLeafBrushes extends BSPLump:
	var leaf_brushes : Array[int] # unsigned short[]
	func parse_from_bytes(bytes:PackedByteArray):
		super(bytes)
		for i in range(0,round(len(bytes)/2)):
			leaf_brushes.append(get_unsigned16())

class BSPHeader extends Object:
	var ident : String
	var version : int
	var lumps : Array[BSPLumpEntry] # There are always 64 lumps
	var map_version : int
	func parse_from_BSPFile(file:BSPFile):
		ident = file.get_string_of_length(4)
		version = file.get_unsigned32()
		BSPHandler.bsp_version = version
		for i in range(0,64):
			#print("Lump ",i+1," of ",64)
			var lmp = BSPLumpEntry.new()
			lmp.readEntryFromBSPFile(file)
			lumps.append(lmp)
		map_version = file.get_unsigned32()
		pass

static func LoadBSP(bsp_path) -> BSPFile:
	#print("Loading BSP...")
	var file = BSPFile.new()
	if file.load_bsp_from_bytes(FA.get_file_as_bytes(bsp_path)) != null:
		return null
	return file

static func _build_mesh_with_uvs(file: BSPFile, face_indices: Array[int]):
	var final_mesh = ArrayMesh.new()
	
	var imgOut = FileAccess.open("res://LUMP_LIGHTING.lmp",FileAccess.WRITE)
	imgOut.store_buffer(file.lumps[BSPLumps.LUMP_LIGHTING].data)
	imgOut.close()
	
	# Group faces by their TexData ID
	var groups = {} # int -> Array[int]
	for f_idx in face_indices:
		var face = file.lumps[BSPLumps.LUMP_FACES].faces[f_idx]
		var t_info = file.lumps[BSPLumps.LUMP_TEXINFO].textures[face.texinfo]
		if not groups.has(t_info.texdata):
			groups[t_info.texdata] = []
		groups[t_info.texdata].append(f_idx)
	
	var tex_info_lump = file.lumps[BSPLumps.LUMP_TEXINFO]
	var tex_data_lump = file.lumps[BSPLumps.LUMP_TEXDATA]
	var faces_lump = file.lumps[BSPLumps.LUMP_FACES]
	var start_x = 0
	var start_y = 0
	var img_light = Image.create_empty(2048,2048,false,Image.FORMAT_RGB8)
	var coordinate_pairs = []
	# Build a separate surface for each texture
	for texdata_id in groups:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
			
		for f_idx in groups[texdata_id]:
			var face : BSPFace = faces_lump.faces[f_idx]
			var verts = faces_lump.get_verticies_for_id(file, f_idx)
			
			if verts.size() < 3: continue

			# Get texture math from the lumps
			var t_info = tex_info_lump.textures[face.texinfo]
			var t_data = tex_data_lump.textures[t_info.texdata]
			
			# UV Vectors (Source format: [x, y, z, offset])
			var u_v = Vector3(t_info.textureVecs[0][0], t_info.textureVecs[0][2], t_info.textureVecs[0][1])
			var u_o = t_info.textureVecs[0][3]
			var v_v = Vector3(t_info.textureVecs[1][0], t_info.textureVecs[1][2], t_info.textureVecs[1][1])
			var v_o = t_info.textureVecs[1][3]
			var ul_v = Vector3(t_info.lightmapVecs[0][0], t_info.lightmapVecs[0][2], t_info.lightmapVecs[0][1])/53
			var ul_o = t_info.lightmapVecs[0][3]
			var vl_v = Vector3(t_info.lightmapVecs[1][0], t_info.lightmapVecs[1][2], t_info.lightmapVecs[1][1])/53
			var vl_o = t_info.lightmapVecs[1][3]
			var maxLMSX = 0
			var maxLMSY = 0
			# 4. Divide by the Luxel size + 1 (Source adds 1 to the size for padding)
			#print("Start_X is now ",start_x)
			#print("Starting image at size ",face.LightmapTextureSizeInLuxels[0]," by ",face.LightmapTextureSizeInLuxels[1])
			#if maxLMSX < start_x + face.LightmapTextureSizeInLuxels[0]:
			#	maxLMSX = start_x + face.LightmapTextureSizeInLuxels[0]
			if maxLMSY - start_y < face.LightmapTextureSizeInLuxels[1]:
				maxLMSY += face.LightmapTextureSizeInLuxels[1]
			if start_x + face.LightmapTextureSizeInLuxels[0] > 2048:
				#print("Shifting at 2048? Tried adding from ",start_x)
				start_x = 0
				start_y = maxLMSY + face.LightmapTextureSizeInLuxels[1] + 10# Donovan, don't delete this again. Its purpose is to make it so that the maximum BB for a texture is where we move next.
			if start_y + face.LightmapTextureSizeInLuxels[1] > 2048:
				push_error("PARSE ERROR: Lightmap area exceeded luxelmap texture size!")
			coordinate_pairs.append([Vector2(start_x,start_y),Vector2(face.LightmapTextureSizeInLuxels[0],face.LightmapTextureSizeInLuxels[1])])
			for y in range(0,face.LightmapTextureSizeInLuxels[1]):
				for x in range(0,face.LightmapTextureSizeInLuxels[0]):
					var c = Color()
					var r_raw = file.lumps[BSPLumps.LUMP_LIGHTING].data[face.lightofs + ((y * face.LightmapTextureSizeInLuxels[0] + x) * 4)]
					var g_raw = file.lumps[BSPLumps.LUMP_LIGHTING].data[face.lightofs + ((y * face.LightmapTextureSizeInLuxels[0] + x) * 4) + 1]
					var b_raw = file.lumps[BSPLumps.LUMP_LIGHTING].data[face.lightofs + ((y * face.LightmapTextureSizeInLuxels[0] + x) * 4) + 2]
					#var e_raw = file.lumps[BSPLumps.LUMP_LIGHTING].data[face.lightofs + ((y * face.LightmapTextureSizeInLuxels[0] + x) * 4) + 3]
					c.r8 = r_raw
					c.g8 = g_raw
					c.b8 = b_raw
					if x == face.LightmapTextureSizeInLuxels[0] - 1 or y == face.LightmapTextureSizeInLuxels[1] - 1:
						c.r = 1
						c.g = 0
						c.b = 0
					#c.r = (r_raw * pow(2.0,e_raw-128.0)) / 255.0
					#c.g = (g_raw * pow(2.0,e_raw-128.0)) / 255.0
					#c.b = (b_raw * pow(2.0,e_raw-128.0)) / 255.0
					img_light.set_pixel(start_x + x,start_y + y,c)
			# Fan triangulate and calculate UVs
			for i in range(1, verts.size() - 1):
				var triangle = [verts[0], verts[i], verts[i+1]]
				for v in triangle:
					# THE FIX: Calculate UV using BSP coords, then divide by texture size
					var u = (v.dot(u_v) + u_o) / (t_data.width)
					var v_coord = (v.dot(v_v) + v_o) / (t_data.height)
					var u_raw = v.dot(ul_v) + ul_o
					var v_raw = v.dot(vl_v) + vl_o

					# 2. Subtract the minimums (this shifts the texture to the start of the face)
					# 3. Add 0.5 for half-pixel offset (to center the sampling)
					var u_local = (u_raw - face.LightmapTextureMinsInLuxels[0])
					var v_local = (v_raw - face.LightmapTextureMinsInLuxels[1])
					
					#var final_ul = (u_local + start_x) / 2048.0
					#var final_vl = (v_local + start_y) / 2048.0
					var final_ul = (u_raw + start_x)/ (face.LightmapTextureSizeInLuxels[0] + 1.0)
					var final_vl = (v_raw + start_y)/ (face.LightmapTextureSizeInLuxels[0] + 1.0)
					#var final_ul = (u_local + start_x) / (face.LightmapTextureSizeInLuxels[0] + 1.0)
					#var final_vl = (v_local + start_y) / (face.LightmapTextureSizeInLuxels[1] + 1.0)
					#st.set_uv2(Vector2(1,1))
					st.set_uv2(Vector2(final_ul, final_vl))
					
					st.set_uv(Vector2(u, v_coord))
					st.add_vertex(v / 53.0) # Apply the scale factor here
			start_x += face.LightmapTextureSizeInLuxels[0] + 10
		
		st.generate_normals()
		st.generate_tangents() # Helpful for Source shaders later
		
		# Commit this texture group as its own surface
		final_mesh = st.commit(final_mesh)
		
		# Apply the material to the last surface added
		img_light.save_png("res://textures/bspldr_light.png")
		var mat = _get_material_for_texdata(file, texdata_id)
		var tex_light = ImageTexture.create_from_image(img_light)
		mat.set_shader_parameter("lightmap_atlas",tex_light)
		var surface_count = final_mesh.get_surface_count() - 1
		final_mesh.surface_set_material(surface_count, mat)
		
	return [final_mesh, img_light]

static func _build_mesh_from_verts(vertarrays:Array):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vertices in vertarrays:
		if vertices.size() < 3:
			print("Invalid quantity for vertarray")
		else:
			for i in range(1, vertices.size() - 1):
				st.add_vertex(vertices[0]/53) # Root vertex
				st.add_vertex(vertices[i]/53) # Current vertex
				st.add_vertex(vertices[i + 1]/53) # Next vertex

	st.generate_normals() # This handles the lighting math for you
	return st.commit()

static func _get_model_brush_list(file: BSPFile, model_index: int) -> Array[int]:
	var model = file.lumps[BSPLumps.LUMP_MODELS].models[model_index]
	var found_brushes : Array[int] = []

	# ---- WORKAROUND FOR SUB-MODELS (Model 1+) ----
	# Sub-models don't traverse LUMP_NODES correctly. Map them via their faces instead!
	if model_index > 0:
		var faces_lump = file.lumps[BSPLumps.LUMP_FACES]
		var brushes_lump = file.lumps[BSPLumps.LUMP_BRUSHES]
		var brush_sides_lump = file.lumps[BSPLumps.LUMP_BRUSHSIDES]
		
		var start_face = model.firstface
		var end_face = model.firstface + model.numfaces
		
		for f_idx in range(start_face, end_face):
			var face = faces_lump.faces[f_idx]
			
			# Scan brushes to see which one contains this face's plane
			for b_idx in range(brushes_lump.brushes.size()):
				if b_idx in found_brushes:
					continue
					
				var brush = brushes_lump.brushes[b_idx]
				var match_found := false
				
				for side_idx in range(brush.firstside, brush.firstside + brush.numsides):
					var side = brush_sides_lump.brush_sides[side_idx]
					if side.planenum == face.planenum:
						match_found = true
						break
						
				if match_found:
					found_brushes.append(b_idx)
					break
		return found_brushes

	# ---- ORIGINAL WORKING STACK WALKER FOR WORLDSPAWN (Model 0) ----
	var stack = [model.headnode]
	var node_lump = file.lumps[BSPLumps.LUMP_NODES]
	var leaf_lump = file.lumps[BSPLumps.LUMP_LEAFS]
	var leafbrush_lump = file.lumps[BSPLumps.LUMP_LEAFBRUSHES]

	while stack.size() > 0:
		var current = stack.pop_back()

		if current >= 0: 
			var node = node_lump.nodes[current]
			stack.append(node.children[0])
			stack.append(node.children[1])
		else: 
			var leaf_idx = -(current + 1)
			var leaf = leaf_lump.leafs[leaf_idx]

			for i in range(leaf.numleafbrushes):
				var lookup_idx = leaf.firstleafbrush + i
				if len(leafbrush_lump.leaf_brushes) > lookup_idx:
					var actual_brush_idx = leafbrush_lump.leaf_brushes[lookup_idx]

					if not actual_brush_idx in found_brushes:
						found_brushes.append(actual_brush_idx)

	return found_brushes

static func o_get_model_brush_list(file:BSPFile,model_index: int) -> Array[int]:
	var model = file.lumps[BSPLumps.LUMP_MODELS].models[model_index]
	var found_brushes : Array[int] = []

	# We start at the headnode and walk down to every child leaf
	var stack = [model.headnode]

	var node_lump = file.lumps[BSPLumps.LUMP_NODES]
	var leaf_lump = file.lumps[BSPLumps.LUMP_LEAFS]
	var leafbrush_lump = file.lumps[BSPLumps.LUMP_LEAFBRUSHES]

	while stack.size() > 0:
		var current = stack.pop_back()

		if current >= 0: 
			# It's a Node (LUMP_NODES index)
			var node = node_lump.nodes[current]
			stack.append(node.children[0])
			stack.append(node.children[1])
		else: 
			# It's a Leaf! Indices are negative: leaf_index = -(index + 1)
			var leaf_idx = -(current + 1)
			var leaf = leaf_lump.leafs[leaf_idx]

			# Now we look up the brushes associated with this specific leaf
			for i in range(leaf.numleafbrushes):
				var lookup_idx = leaf.firstleafbrush + i
				if len(leafbrush_lump.leaf_brushes) > lookup_idx:
					var actual_brush_idx = leafbrush_lump.leaf_brushes[lookup_idx]

					# Prevent duplicates (multiple leaves can share a brush)
					if not actual_brush_idx in found_brushes:
						found_brushes.append(actual_brush_idx)

	return found_brushes

static func get_bsp_as_mesh(file:BSPFile) -> MeshInstance3D:
	var m = MeshInstance3D.new()
	m.mesh = _build_mesh_from_verts(file.lumps[BSPLumps.LUMP_MODELS].get_verticies_by_id(file,0))
	return m

static func get_model_mesh(file:BSPFile,mesh_id:int):
	var modellmp : BSPLumpModels = file.lumps[BSPLumps.LUMP_MODELS]
	#var m = _build_mesh_from_verts(modellmp.get_verticies_by_id(file,mesh_id))
	var m = _build_mesh_with_uvs(file,modellmp.get_list_of_face_indicies_by_id(file,mesh_id))
	return m[0]

static func get_model_mesh_and_lightmap(file:BSPFile,mesh_id:int):
	var modellmp : BSPLumpModels = file.lumps[BSPLumps.LUMP_MODELS]
	#var m = _build_mesh_from_verts(modellmp.get_verticies_by_id(file,mesh_id))
	var m = _build_mesh_with_uvs(file,modellmp.get_list_of_face_indicies_by_id(file,mesh_id))
	return m

static func _clean_texture_path(path: String) -> String:
	# Removes cubemap suffixes like _-512_-512_256
	var regex = RegEx.new()
	regex.compile("_-?\\d+_-?\\d+_-?\\d+$")
	var cleaned = regex.sub(path, "")
	
	# Also strip 'maps/mapname/' prefix if it exists
	if cleaned.begins_with("maps/"):
		var parts = cleaned.split("/")
		if parts.size() > 2:
			# Rejoin everything after the second slash
			cleaned = "/".join(parts.slice(2))
			
	return cleaned
static func _script_class_exists(class_name_string: String) -> bool:
	var global_classes = ProjectSettings.get_global_class_list()
	for item in global_classes:
		if item["class"] == class_name_string:
			return true
	return false

static func _get_material_for_texdata(file: BSPFile, texdata_id: int) -> ShaderMaterial:
	if file.material_cache.has(texdata_id):
		return file.material_cache[texdata_id]
	
	var mat = preload("res://materials/TemplateMaterial.tres").duplicate()
	
	# Get the name using the logic we discussed
	var string_table = file.lumps[BSPLumps.LUMP_TEXDATA_STRING_TABLE]
	var tex_name = string_table.lookup_from_id(file, texdata_id)
	
	# PREPROCESSOR-ISH CHECK:
	# Try to load the texture ONLY if your VTF loader exists
	var tex_resource = null
	if _script_class_exists("VTFHandler"):
		# This is where you'd call your other script
		# tex_resource = VTFHandler.load_vtf_as_texture(tex_name)
		tex_resource = VTFHandler.get_texture_from_path("materials/" + _clean_texture_path(tex_name) + ".vtf")
		if tex_resource == null or tex_resource is int:
			tex_resource = VTFHandler.get_texture_from_path("./source/materials/" + _clean_texture_path(tex_name).to_lower() + ".vtf")
			if tex_resource is int:
				tex_resource = null
		pass
	
	if tex_resource:
		mat.set_shader_parameter("albedo_texture",tex_resource)
	else:
		# Fallback: Give it a unique color based on the name hash 
		# so different textures look different in-engine
		# Inside your material proxy function
		print("Failed to load " + _clean_texture_path(tex_name))
		var hash_val = _clean_texture_path(tex_name).hash()
		# Use fmod with a larger prime or just wrap the raw hash
		var hue = abs(hash_val % 1000) / 1000.0 
		mat.set_shader_parameter("albedo_texture",VTFHandler.get_image_from_path("vtfmissing.vtf"))
	
	file.material_cache[texdata_id] = mat
	return mat

static func _get_planes_for_brush(file:BSPFile, brush_idx: int) -> Array[Plane]:
	var planes: Array[Plane] = []
	var brush = file.lumps[BSPLumps.LUMP_BRUSHES].brushes[brush_idx]

	# Brush sides are stored contiguously
	for i in range(brush.firstside, brush.firstside + brush.numsides):
		# 1. Get the Side
		var side = file.lumps[BSPLumps.LUMP_BRUSHSIDES].brush_sides[i]

		# 2. Get the Plane from the index we fixed earlier
		var bsp_plane = file.lumps[BSPLumps.LUMP_PLANES].planes[side.planenum]

		# 3. Convert to Godot Plane (Normal and Distance)
		# Note: Depending on your Plane parser, 
		# you might need to flip the axis here (e.g., Vector3(n.x, n.z, -n.y))
		var godot_plane = bsp_plane
		planes.append(godot_plane)

	return planes

static func get_model_collision_mesh(file: BSPFile, model_idx: int) -> ConvexPolygonShape3D:
	var brush_indices = _get_model_brush_list(file, model_idx)
	var all_points = PackedVector3Array()
	
	# Grab the model's baked origin point
	var target_model = file.lumps[BSPLumps.LUMP_MODELS].models[model_idx]
	# Map the BSP origin to Godot space (X, Z, -Y) and scale it!
	var model_origin = Vector3(target_model.origin.x, target_model.origin.z, -target_model.origin.y) / 53.0

	for b_idx in brush_indices:
		var planes = _get_planes_for_brush(file, b_idx)
		var points = Geometry3D.compute_convex_mesh_points(planes)
		for p in points:
			var scaled_point = p / 53.0
			
			# ---- SUBTRACT THE ORIGIN ----
			# This moves the vertices into true LOCAL space around (0,0,0)
			var local_point = scaled_point - model_origin
			all_points.append(local_point)
		
		if all_points.size() >= 4:
			break 

	var shape = ConvexPolygonShape3D.new()
	shape.points = all_points
	return shape

static func o_get_model_collision_mesh(file:BSPFile, model_idx: int) -> ConvexPolygonShape3D:
	var brush_indices = _get_model_brush_list(file, model_idx)
	var all_points = PackedVector3Array()

	for b_idx in brush_indices:
		var planes = _get_planes_for_brush(file, b_idx)
		var points = Geometry3D.compute_convex_mesh_points(planes)
		for p in points:
			all_points.append(p / 53.0)

	var shape = ConvexPolygonShape3D.new()
	shape.points = all_points
	return shape


# Source Engine content constants
const CONTENTS_SOLID = 0x1
const CONTENTS_WINDOW = 0x2
const CONTENTS_GRATE = 0x8
const CONTENTS_SKY = 0x20000

static func _should_skip_contents(contents: int) -> bool:
	# If it's a skybox brush, we definitely skip it
	if contents & CONTENTS_SKY:
		return true
		
	# If it doesn't contain standard player-blocking flags (solid, windows, grates), skip it
	if not (contents & (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE)):
		return true
		
	return false

## Creates a huge starting polygon aligned with a plane to carve down
static func _generate_large_polygon_on_plane(plane: Plane) -> PackedVector3Array:
	var u = Vector3.UP if abs(plane.normal.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT
	var tangent = plane.normal.cross(u).normalized()
	var bitangent = plane.normal.cross(tangent).normalized()
	
	var center = plane.normal * plane.d
	var half_size = 1000.0 # Large enough to span normal Source brush boundaries
	
	var poly = PackedVector3Array()
	poly.append(center + (tangent * half_size) + (bitangent * half_size))
	poly.append(center + (tangent * -half_size) + (bitangent * half_size))
	poly.append(center + (tangent * -half_size) + (bitangent * -half_size))
	poly.append(center + (tangent * half_size) + (bitangent * -half_size))
	return poly

## Standard Sutherland-Hodgman polygon clipping against a 3D plane
static func _clip_polygon_by_plane(poly: PackedVector3Array, plane: Plane) -> PackedVector3Array:
	var clipped_poly = PackedVector3Array()
	if poly.size() == 0: 
		return clipped_poly
		
	var out_v = poly[poly.size() - 1]
	var out_dist = plane.distance_to(out_v)
	
	for in_v in poly:
		var in_dist = plane.distance_to(in_v)
		
		# If transitioning across the plane boundary, compute intersection point
		if (out_dist < 0.0 and in_dist >= 0.0) or (out_dist >= 0.0 and in_dist < 0.0):
			var t = out_dist / (out_dist - in_dist)
			clipped_poly.append(out_v.lerp(in_v, t))
			
		# Keep points on the valid "inside" (front) side of the plane
		if in_dist >= 0.0:
			clipped_poly.append(in_v)
			
		out_v = in_v
		out_dist = in_dist
		
	return clipped_poly

## Compiles a single ConcavePolygonShape3D for a specific BSP model ID by walking the tree.## Generates a collision shape for a model using only its face array indices
static func get_model_concave_collision_mesh(bsp_file, model_idx: int) -> ConcavePolygonShape3D:
	var concave_shape = ConcavePolygonShape3D.new()
	var faces_triangles: PackedVector3Array = []
	
	var target_model = bsp_file.lumps[BSPLumps.LUMP_MODELS].models[model_idx]
	
	var faces_lump = bsp_file.lumps[BSPLumps.LUMP_FACES]
	var surfedges_lump = bsp_file.lumps[BSPLumps.LUMP_SURFEDGES]
	var edges_lump = bsp_file.lumps[BSPLumps.LUMP_EDGES]
	var vertices_lump = bsp_file.lumps[BSPLumps.LUMP_VERTEXES]
	
	var start_face = target_model.firstface
	var end_face = target_model.firstface + target_model.numfaces
	
	for face_idx in range(start_face, end_face):
		var face = faces_lump.faces[face_idx]
		
		# Gather the vertices that make up this specific face loop
		var face_vertices: PackedVector3Array = []
		
		for i in range(face.numedges):
			var surfedge_idx = face.firstedge + i
			var edge_val = surfedges_lump.data[surfedge_idx]
			
			var edge = edges_lump.bspedges[abs(edge_val)]
			var vertex_idx : int
			
			# If the surfedge index is positive, follow the edge from start to end.
			# If negative, the edge is traversed backwards.
			if edge_val >= 0:
				vertex_idx = edge.v1
			else:
				vertex_idx = edge.v2
				
			var bsp_vertex = vertices_lump.verts[vertex_idx]
			
			# Map standard coordinate system to Godot (X, Z, -Y)
			var godot_vertex = Vector3(bsp_vertex.x, bsp_vertex.z, -bsp_vertex.y) / 53.3333
			face_vertices.append(godot_vertex)
			
		# Fan triangulate the face vertices (works since BSP faces are strictly planar & convex)
		if face_vertices.size() >= 3:
			for j in range(1, face_vertices.size() - 1):
				faces_triangles.append(face_vertices[0])
				faces_triangles.append(face_vertices[j])
				faces_triangles.append(face_vertices[j + 1])
				
	concave_shape.data = faces_triangles
	return concave_shape
## Takes an array of Godot Plane objects and derives a flat triangle array
static func _carve_brush_into_triangles(brush_planes: Array[Plane]) -> PackedVector3Array:
	var total_tris: PackedVector3Array = []
	
	for i in range(brush_planes.size()):
		var target_plane = brush_planes[i]
		
		# 1. Start with a massive pseudo-infinite polygon aligned on our target plane
		var face_poly = _generate_large_polygon_on_plane(target_plane)
		
		# 2. Slice this polygon against every single other plane belonging to the brush
		for j in range(brush_planes.size()):
			if i == j: 
				continue
			face_poly = _clip_polygon_by_plane(face_poly, brush_planes[j])
			if face_poly.size() < 3: 
				break # The face was completely sliced out of existence
				
		# 3. If the polygon survived the meat-grinder, turn it into triangles
		if face_poly.size() >= 3:
			# Simple fan triangulation (works flawlessly because BSP brushes are strictly convex)
			for k in range(1, face_poly.size() - 1):
				total_tris.append(face_poly[0])
				total_tris.append(face_poly[k])
				total_tris.append(face_poly[k + 1])
				
	return total_tris

## Generates world collision without ever touching a leaf or a tree node
static func get_world_collision_mesh(bsp_file) -> ConcavePolygonShape3D:
	var concave_shape = ConcavePolygonShape3D.new()
	var faces_triangles: PackedVector3Array = []
	
	# 1. Grab the first model (Worldspawn) from LUMP_MODELS
	# A dmodel_t has: mins[3], maxs[3], origin[3], headnode, firstface, numfaces, firstbrush, numbrushes
	var world_model = bsp_file.lumps[BSPLumps.LUMP_MODELS].models[0] 
	
	var brushes_lump = bsp_file.lumps[BSPLumps.LUMP_BRUSHES]
	var brush_sides_lump = bsp_file.lumps[BSPLumps.LUMP_BRUSHSIDES]
	var planes_lump = bsp_file.lumps[BSPLumps.LUMP_PLANES]
	
	# 2. Iterate ONLY through the brushes owned by worldspawn
	var start_brush = world_model.firstbrush
	var end_brush = world_model.firstbrush + world_model.numbrushes
	
	for brush_idx in range(start_brush, end_brush):
		var brush = brushes_lump.brushes[brush_idx]
		
		# Skip non-solid / trigger / volume contents flags if necessary
		if (brush.contents & 0x1) == 0: # CONTENTS_SOLID check
			continue
			
		var brush_planes: Array[Plane] = []
		
		# Gather the planes forming this solid brush
		for side_idx in range(brush.firstside, brush.firstside + brush.numsides):
			var side = brush_sides_lump.sides[side_idx]
			var bsp_plane = planes_lump.planes[side.planenum]
			
			# Map standard Source coordinates (X Y Z) to Godot (X Z -Y)
			var godot_normal = Vector3(bsp_plane.normal.x, bsp_plane.normal.z, -bsp_plane.normal.y)
			var godot_plane = Plane(godot_normal, bsp_plane.dist / 53.3333) # Hammer Units conversion
			brush_planes.append(godot_plane)
			
		# 3. Intersect the planes to form a convex polyhedron poly
		# (Your existing brush-to-polygon carving logic goes here)
		var brush_tris = _carve_brush_into_triangles(brush_planes)
		faces_triangles.append_array(brush_tris)
		
	concave_shape.data = faces_triangles
	return concave_shape

## Helper to recursively walk the node tree down to the leaves
static func _find_leaves_under_node(node_id: int, bsp_file, out_leaves: Array[int]) -> void:
	if node_id < 0:
		# Use a 16-bit mask to strip out sign extension garbage
		var leaf_idx = (~node_id) & 0xFFFF
		out_leaves.append(leaf_idx)
		return
		
	var nodes_lump = bsp_file.lumps[BSPLumps.LUMP_NODES]
	var node = nodes_lump.nodes[node_id]
	_find_leaves_under_node(node.children[0], bsp_file, out_leaves)
	_find_leaves_under_node(node.children[1], bsp_file, out_leaves)
	
static func _fallback_get_all_models_as_meshes(file:BSPFile) -> Array:
	var ms = []
	var modellmp : BSPLumpModels = file.lumps[BSPLumps.LUMP_MODELS]
	for m_id in range(0,len(modellmp.models)):
		var m = MeshInstance3D.new()
		m.mesh = _build_mesh_from_verts(modellmp.get_verticies_by_id(file,m_id))
		m.position = modellmp.models[m_id].origin
		ms.append(m)
	return ms

static func get_all_models_as_meshes(file: BSPFile) -> Array:
	var ms = []
	var modellmp : BSPLumpModels = file.lumps[BSPLumps.LUMP_MODELS]
	
	for m_id in range(0, modellmp.models.size()):
		var m = MeshInstance3D.new()
		# We call the new textured mesh builder instead of the old vertex-only one
		m.mesh = get_model_mesh(file, m_id)
		m.position = modellmp.models[m_id].origin
		ms.append(m)
		
	return ms

static func get_all_models_as_brush_meshes(file:BSPFile) -> Array:
	var ms = []
	var modellmp : BSPLumpModels = file.lumps[BSPLumps.LUMP_MODELS]
	for m_id in range(0,len(modellmp.models)):
		var m = MeshInstance3D.new()
		m.mesh = get_model_collision_mesh(file,m_id)
		m.position = modellmp.models[m_id].origin
		ms.append(m)
	return ms

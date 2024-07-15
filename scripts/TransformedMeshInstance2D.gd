extends MeshInstance2D
class_name TransformedMeshInstance2D


var xform:Transform3D
var _rq := false


@export var cullMode:BaseMaterial3D.CullMode:
	set(value):
		cullMode = value
		queueRecalc()
@export var baseMesh:Mesh:
	set(value):
		baseMesh = value
		queueRecalc()
@export var xPosition:Vector3:
	set(value):
		xPosition = value
		queueRecalc()
@export var xRotation:Vector3:
	set(value):
		xRotation = value
		queueRecalc()
@export var xScale:Vector3:
	set(value):
		xScale = value
		queueRecalc()
@export var mat:Material:
	set(value):
		if mat is BaseMaterial3D:
			mat = value
			texture = mat.albedo_texture


func _ready():
	queueRecalc()


func queueRecalc():
	if not _rq:
		_recalc.call_deferred()
		_rq = true


func _comp(a:Array, b:Array) -> bool:
	var h0 = (a[0].z + a[1].z + a[2].z) / 3
	var h1 = (b[0].z + b[1].z + b[2].z) / 3
	return h0 > h1


func _normToCol(norm:Vector3) -> Color:
	var d = Vector3(-0.57735026919, -0.57735026919, 0.57735026919).angle_to(norm)
	d = 1 - (d / 10)
	return Color(d, d, d)


func _recalc():
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(baseMesh,0)
	var array_mesh := surface_tool.commit()
	
	xform = Transform3D()
	
	xform = xform.rotated(Vector3(0, 0, 1), deg_to_rad(xRotation.z))
	xform = xform.rotated(Vector3(1, 0, 0), deg_to_rad(xRotation.x))
	xform = xform.rotated(Vector3(0, 1, 0), deg_to_rad(xRotation.y))
	
	xform = xform.scaled(xScale)
	
	xform = xform.translated(xPosition)
	
	var _tool = MeshDataTool.new()
	_tool.create_from_surface(array_mesh, 0)
	
	for i in _tool.get_vertex_count():
		var vert := _tool.get_vertex(i)
		vert = vert * xform
		_tool.set_vertex(i, vert)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var verts = []
	for i in _tool.get_face_count():
		var norm := _tool.get_face_normal(i)
		var cond:bool
		match cullMode:
			BaseMaterial3D.CullMode.CULL_BACK:
				cond = Vector3.FORWARD.angle_to(norm) < (PI /  2)
			BaseMaterial3D.CullMode.CULL_FRONT:
				cond = Vector3.FORWARD.angle_to(norm) > (PI /  2)
			BaseMaterial3D.CullMode.CULL_DISABLED:
				cond = true
			_:
				cond = Vector3.FORWARD.angle_to(norm) < (PI /  2)
		if cond:
			var v0 = _tool.get_face_vertex(i, 0)
			var v1 = _tool.get_face_vertex(i, 1)
			var v2 = _tool.get_face_vertex(i, 2)
			verts.append([
				_tool.get_vertex(v0),
				_tool.get_vertex(v1),
				_tool.get_vertex(v2),
				_tool.get_face_normal(i),
				_tool.get_vertex_uv(v0),
				_tool.get_vertex_uv(v1),
				_tool.get_vertex_uv(v2),
				_tool.get_vertex_uv2(v0),
				_tool.get_vertex_uv2(v1),
				_tool.get_vertex_uv2(v2),
			])
	
	verts.sort_custom(_comp)
	
	for i in verts:
		st.set_color(_normToCol(i[3]))
		
		st.set_uv(i[4])
		st.set_uv2(i[7])
		st.add_vertex(i[0])
		
		st.set_uv(i[5])
		st.set_uv2(i[8])
		st.add_vertex(i[1])
		
		st.set_uv(i[6])
		st.set_uv2(i[9])
		st.add_vertex(i[2])
	
	mesh = st.commit()
	mesh.surface_set_material(0, mat)
	
	_rq = false

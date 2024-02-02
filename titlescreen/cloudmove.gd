extends MeshInstance3D


func _ready():
	pass


func _process(delta):
	material_override.uv1_offset.x += delta / 900

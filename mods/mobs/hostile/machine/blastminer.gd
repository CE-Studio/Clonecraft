extends Entity


@onready var head:Node3D = $blastminer/body/head
@onready var neck1:Node3D = $blastminer/body/head/neckrod
@onready var neck2:Node3D = $blastminer/body/neckpiston


func _process(delta: float) -> void:
	neck1.look_at(neck2.global_position)
	neck2.look_at(neck1.global_position)


func _movement_process(delta:float) -> void:
	pass


func damage(amount:float) -> void:
	pass


func die() -> void:
	pass


func animate_damage(amount:float) -> void:
	pass

extends Entity


@onready var head:Node3D = $blastminer/body/head
@onready var neck1:Node3D = $blastminer/body/head/neckrod
@onready var neck2:Node3D = $blastminer/body/neckpiston
@onready var anim_tree:AnimationTree = $animationTree


func _process(delta: float) -> void:
	neck1.look_at(neck2.global_position)
	neck2.look_at(neck1.global_position)
	anim_tree[&"parameters/speed/blend_amount"] = velocity.length()


func _movement_process(delta:float) -> void:
	pass


func die() -> void:
	pass


func animate_damage(amount:float) -> void:
	$animationPlayer3.play("hurt")

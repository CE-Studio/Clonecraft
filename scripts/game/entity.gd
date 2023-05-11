extends CharacterBody3D
class_name Entity


var SPEED := 5.0
var JUMP_VELOCITY := 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY:float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

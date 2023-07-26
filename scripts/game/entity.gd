extends CharacterBody3D
class_name Entity


var SPEED := 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var TERMINAL_VELOCITY:float = ProjectSettings.get_setting("gameplay/physics/terminal_velocity")
var GRAVITY:float = ProjectSettings.get_setting("physics/3d/default_gravity")

## Defines some basic abillities of the entity.[br]
## Scale is a multiplier, size is absolute.
var abilities := {
    "allowFlight":false,
    "isFlying":false,
    "allowBuild":false,
    "scale":{
        "uniform":1.0,
        "x":1.0,
        "y":1.0,
        "z":1.0,
        "speed":1.0,
        "jump":1.0,
        "range":1.0,
        "reach":1.0,
        "inventory":1.0,
    },
    "size":{
        "x":1.0,
        "y":1.0,
        "z":1.0,
        "speed":5.0,
        "jump":8.0,
        "reach":0.0,
        "inventory":0.0,
    },
}

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = abilities.size.jump

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

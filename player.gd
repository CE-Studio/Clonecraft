extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8
const SENSITIVITY = 200

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var head
var cam
var armpointx
var armpointy
var movedist = 0
var animcurspeed = 0

func _ready():
    head = get_child(1)
    cam = head.get_child(0)
    armpointy = get_child(4)
    armpointx = armpointy.get_child(0)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
func _process(delta):
    armpointy.rotation.y = lerp_angle(armpointy.rotation.y, head.rotation.y, delta * 20)
    armpointx.rotation.x = lerp_angle(armpointx.rotation.x, cam.rotation.x, delta * 20)
    armpointx.position = Vector3(lerp(armpointx.position.x, sin(movedist) / 40, delta * 20) * animcurspeed, lerp(armpointx.position.y, ((1 - abs(cos(movedist))) / 80)  * animcurspeed, delta * 20), 0)
    
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        else:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseMotion:
        var mx = -(event.relative.x / SENSITIVITY)
        var my = -(event.relative.y / (SENSITIVITY / 2))
        head.rotate_y(mx)
        cam.rotate_x(my)
        cam.rotation.x = clamp(cam.rotation.x, -1.5708, 1.5708)

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    if Input.is_action_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
    movedist += (abs(velocity.x) + abs(velocity.z)) * delta
    animcurspeed = lerp(animcurspeed, clamp((abs(velocity.x) + abs(velocity.z)), 0, 1), delta * 10)

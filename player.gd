extends CharacterBody3D

class_name Player

var SPEED = 5.0
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
var bm
var vt:VoxelToolTerrain
var lookingAt
var bo
var cloudmat

var tickrange := 100
var ticknumber := 512

var abillities := {"allowFlight":false, "isFlying":false}
var fcheck = 1.0

func _ready():
    head = get_child(1)
    cam = head.get_child(0)
    armpointy = get_child(4)
    armpointx = armpointy.get_child(0)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    bm = $"/root/BlockManager"
    vt = $"/root/Node3D/VoxelTerrain".get_voxel_tool()
    bo = $"/root/Node3D/blockOutline"
    cloudmat = $"./clouds"
    cloudmat = cloudmat.material_override
    
func _process(delta):
    armpointy.rotation.y = lerp_angle(armpointy.rotation.y, head.rotation.y, delta * 20)
    armpointx.rotation.x = lerp_angle(armpointx.rotation.x, cam.rotation.x, delta * 20)
    armpointx.position = Vector3(lerp(armpointx.position.x, sin(movedist) / 40, delta * 20) * animcurspeed, lerp(armpointx.position.y, ((1 - abs(cos(movedist))) / 80)  * animcurspeed, delta * 20), 0)
    cloudmat.uv1_offset.z += delta / 900
    fcheck += delta
    
func _input(event):
    if event.is_action_pressed("ui_accept"):
        if fcheck <= 0.2:
            if abillities["allowFlight"] || abillities["isFlying"]:
                abillities["isFlying"] = not abillities["isFlying"]
        fcheck = 0
    elif event.is_action_pressed("ui_cancel"):
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
        
func ticks():
    var center = position.floor()
    var area = AABB(center - Vector3(tickrange, tickrange, tickrange), 2 * Vector3(tickrange, tickrange, tickrange))
    vt.run_blocky_random_tick(area, ticknumber, bm.rt)

func _physics_process(delta):
    # Add the gravity.
    if (not abillities["isFlying"]) && (not is_on_floor()):
        velocity.y -= gravity * delta

    # Handle Jump.
    if abillities["isFlying"]:
        if Input.is_action_pressed("ui_accept") and not Input.is_action_pressed("game_sneak"):
            velocity.y = JUMP_VELOCITY
        elif Input.is_action_pressed("game_sneak") and not Input.is_action_pressed("ui_accept"):
            velocity.y = -JUMP_VELOCITY
            if is_on_floor():
                abillities["isFlying"] = false
        else:
            velocity.y = 0
    else:
        if Input.is_action_pressed("ui_accept") and is_on_floor():
            velocity.y = JUMP_VELOCITY
        
    if Input.is_action_pressed("ui_up"):
        if Input.is_action_pressed("game_sprint"):
            if Input.is_action_pressed("ui_accept"):
                SPEED = 9
            else:
                SPEED = 8
        else:
            SPEED = 5
    else:
        SPEED = 5
            
    if Input.is_action_pressed("game_sneak"):
        SPEED = 2
        head.position.y = 0.58
        armpointy.position.y = 0.6
    else:
        head.position.y = 0.689
        armpointy.position.y = 0.689

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
    
    lookingAt = vt.raycast(cam.global_position, -1 * cam.global_transform.basis.z.normalized(), 5)
    if lookingAt != null:
        bo.show()
        bo.position = Vector3(lookingAt.position) + Vector3(0.5, 0.5, 0.5)
    else:
        bo.hide()
        
    ticks()

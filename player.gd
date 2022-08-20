class_name Player
extends CharacterBody3D

var SPEED := 5.0
const JUMP_VELOCITY := 8.0
const SENSITIVITY := 200.0

var head:Node3D
var cam:Camera3D
var armPointX:Node3D
var armPointY:Node3D
var blockManager:BlockManager
var voxelTool:VoxelToolTerrain
var lookingAt:VoxelRaycastResult
var blockOutline:MeshInstance3D
var cloudmat:StandardMaterial3D

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var moveDist := 0
var animCurSpeed := 0.0
var tickRange := 100
var tickNumber := 512

var abillities := {
    "allowFlight":false,
    "isFlying":false,
}
var fcheck := 1.0


func _ready():
    head = $"head"
    cam = $"head/Camera3D"
    armPointY = $"armpointy"
    armPointX = $"armpointy/armpointx"
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    blockManager = $"/root/BlockManager"
    voxelTool = $"/root/Node3D/VoxelTerrain".get_voxel_tool()
    blockOutline = $"/root/Node3D/blockOutline"
    cloudmat = $"./clouds".material_override


func _process(delta):
    armPointY.rotation.y = lerp_angle(armPointY.rotation.y, head.rotation.y, delta * 20)
    armPointX.rotation.x = lerp_angle(armPointX.rotation.x, cam.rotation.x, delta * 20)
    armPointX.position = Vector3(
        lerp(armPointX.position.x, sin(moveDist) / 40, delta * 20) * animCurSpeed,
        lerp(armPointX.position.y, ((1 - abs(cos(moveDist))) / 80)  * animCurSpeed, delta * 20),
        0
    )
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
    var area = AABB(
        center - Vector3(tickRange, tickRange, tickRange),
        2 * Vector3(tickRange, tickRange, tickRange)
    )
    voxelTool.run_blocky_random_tick(area, tickNumber, blockManager.runRandomTicks)


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
        armPointY.position.y = 0.6
    else:
        head.position.y = 0.689
        armPointY.position.y = 0.689

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
    moveDist += (abs(velocity.x) + abs(velocity.z)) * delta
    animCurSpeed = lerp(animCurSpeed, clamp((abs(velocity.x) + abs(velocity.z)), 0, 1), delta * 10)

    lookingAt = voxelTool.raycast(cam.global_position, -1 * cam.global_transform.basis.z.normalized(), 5)
    if lookingAt != null:
        blockOutline.show()
        blockOutline.position = Vector3(lookingAt.position) + Vector3(0.5, 0.5, 0.5)
    else:
        blockOutline.hide()

    ticks()

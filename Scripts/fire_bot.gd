extends CharacterBody3D

@onready var camera_controller: Node3D = $Camera_Controller
@onready var spring_arm = $Camera_Controller/spine_ik_target/Camera_Target/SpringArm3D
@onready var cam: Camera3D = $Camera_Controller/spine_ik_target/Camera_Target/SpringArm3D/Camera3D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var locomotion_path = "parameters/Blend2_A/in_a/Locomotion/current"
@onready var blend2a_path = "parameters/Blend2_A/blend_amount"
@onready var blend2b_path = "parameters/Blend2_B/blend_amount"
@onready var aim_blendspace_path = "parameters/BlendSpace2D/blend_position"
@onready var locomotion_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Locomotion/playback")
@onready var locomotion_speed_path = "parameters/TimeScale/scale"

@onready var armature: Node3D = $Armature
@onready var skeleton := $Armature/Skeleton3D
@onready var fire_point: Node3D = $Armature/Skeleton3D/Hands/FirePoint


var FIREBALL = preload("res://fireball.tscn")

var SPEED = 5.0
const JUMP_VELOCITY = 12
var walking_speed = 5.0
var running_speed = 10.0

var running = false
var is_locked = false
var aiming = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
const LOOK_SPEED = 2.5  # Camera sensitivity

@export var player_id = 1

var camera_pitch = 0.0  # Unghiul curent al camerei pe axa X

var xform : Transform3D

# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var crosshair: Node = null

func _ready():
	var vp := get_viewport()
	crosshair = vp.get_node("Crosshair")
	crosshair.visible = false

	if player_id == 1:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if player_id != 1:
		return  # Only the first player controls the camera with the mouse

	if event is InputEventMouseMotion:
		# Rotate horizontally (Y)
		camera_controller.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		
		# Calculate the new rotation angle on X
		var pitch_delta = deg_to_rad(-event.relative.y * sens_vertical)
		camera_pitch = clamp(camera_pitch + pitch_delta, deg_to_rad(-30), deg_to_rad(30))

		# Apply limited rotation on X
		camera_controller.rotation_degrees.x = rad_to_deg(camera_pitch)


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("p%s_left" % [player_id], "p%s_right" % [player_id], "p%s_forward" % [player_id], "p%s_backward" % [player_id])
	
	animation_tree.set("parameters/Locomotion/Run/TimeScale/scale", 2.4)
	
	aiming = Input.is_action_pressed("p%s_aim" % [player_id])
	var aim_started = false

	if aiming:
		$Camera_Controller.position = position
		$Armature/Skeleton3D/spine_ik.start()
		
		set_aiming_camera_mode()
		start_aiming() # Moves hand
		crosshair.visible = true # Show Crosshair
		
		if Input.is_action_just_pressed("p%s_shoot" % [player_id]):
			shoot()
		
		# Înclină tilt_node după sol
		var normal = $RayCast3D.get_collision_normal()
		var tilt_basis = Basis()
		tilt_basis.y = normal
		tilt_basis.x = -transform.basis.z.cross(normal).normalized()
		tilt_basis.z = tilt_basis.x.cross(tilt_basis.y).normalized()

		# tilt_node.transform.basis = tilt_basis.orthonormalized()
		$Armature.rotation.y = $Camera_Controller.rotation.y

		# Set direction in BlendSpace2D
		animation_tree.set("parameters/BlendSpace2D/blend_position", input_dir)

	else:
		aim_started = false
		$Armature/Skeleton3D/spine_ik.stop()
		
		un_aiming_camera_mode()
		stop_aiming() # Moves hand
		crosshair.visible = false # Hide Crosshair
	
		# Make Camera Controller Match the position of myself
		$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)
	
	
	if Input.is_action_pressed("p%s_run" % [player_id]) and !aiming:
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("p%s_jump" % [player_id]) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if running:
		animation_tree.set(locomotion_speed_path, 2.4) # Run
	elif input_dir != Vector2.ZERO:
		animation_tree.set(locomotion_speed_path, 2.4) # Walk
	else:
		animation_tree.set(locomotion_speed_path, 1.0) # Idle normal

	
	# Rotate the camera left and right
	if Input.is_action_pressed("p%s_look_left" % [player_id]):
		$Camera_Controller.rotate_y(deg_to_rad(LOOK_SPEED))
	if Input.is_action_pressed("p%s_look_right" % [player_id]):
		$Camera_Controller.rotate_y(deg_to_rad(-LOOK_SPEED))
	if Input.is_action_pressed("p%s_look_up" % [player_id]):
		camera_controller.rotation_degrees.x -= LOOK_SPEED
	if Input.is_action_pressed("p%s_look_down" % [player_id]):
		camera_controller.rotation_degrees.x += LOOK_SPEED
	# Limits camera rotation on the X axis (up/down)
	camera_controller.rotation_degrees.x = clamp(camera_controller.rotation_degrees.x, -45, 45)
	
	# Locomotion control (StateMachine)
	if is_on_floor():
		if input_dir == Vector2.ZERO:
			locomotion_playback.travel("Idle")
		elif running and !aiming:
			locomotion_playback.travel("Run")
		elif !aiming:
			locomotion_playback.travel("Walk Forward")
		else:
			# in aiming we don't use locomotion
			pass
	else:
		animation_tree.set(locomotion_speed_path, 1.0)
		locomotion_playback.travel("Jump")


	
	var camera_basis = camera_controller.global_transform.basis
	var flat_forward = Vector3(camera_basis.z.x, 0, camera_basis.z.z).normalized()
	var flat_right = Vector3(camera_basis.x.x, 0, camera_basis.x.z).normalized()
	# New Vector3 direction, taking into account the user arrow inputs and the camera rotation
	var direction = (flat_right * input_dir.x + flat_forward * input_dir.y).normalized()
	
	# Rotate the character mesh so that it is oriented towards the direction moving in the relation to the camera
	if input_dir != Vector2(0,0) and !aiming:
		$Armature.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) - 90
	
	# Rotate the character to align with the floor
	if is_on_floor():    # and input_dir != Vector2(0,0)  pentru colturi
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
	
	# Update the velocity and move the character
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()

func _on_fall_zone_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.position = Vector3(0, 1, 0)
		body.velocity = Vector3.ZERO

func start_aiming():
	var t = create_tween()
	t.tween_property(animation_tree, "parameters/Blend2_A/blend_amount", 1.0, 0.04)
	t.tween_property(animation_tree, "parameters/Blend2_B/blend_amount", 1.0, 0.04)

func stop_aiming():
	var t = create_tween()
	t.tween_property(animation_tree, "parameters/Blend2_A/blend_amount", 0.0, 0.04)
	t.tween_property(animation_tree, "parameters/Blend2_B/blend_amount", 0.0, 0.04)

func shoot():
	var fireball = FIREBALL.instantiate()
	get_tree().current_scene.add_child(fireball)
	SoundManager.play_fireball_sound()

	# Poziția fireball-ului = poziția mâinii
	fireball.global_transform.origin = fire_point.global_transform.origin

	# Direcția = direcția camerei
	var dir = -cam.global_transform.basis.z.normalized()
	fireball.direction = dir


func bounce():
	velocity.y = JUMP_VELOCITY * 0.7

func set_aiming_camera_mode():
	# Doar un mic offset pe X și Z — păstrează Y neschimbat pentru stabilitate
	spring_arm.position = Vector3(0.9, 0.47, -3.5)  # sau -4.0 dacă vrei să fie mai aproape

func un_aiming_camera_mode():
	spring_arm.position = Vector3(0.0, 0.47, -2.9)

func update_aim_bones():
	if !aiming:
		return

	var spine_bone_idx = skeleton.find_bone("Spine.002")
	if spine_bone_idx == -1:
		return

	var yaw = $Camera_Controller.rotation.y
	var pitch = camera_pitch

	var bones = []
	var current = spine_bone_idx
	while current != -1:
		bones.append(current)
		var children = skeleton.get_bone_children(current)
		current = children[0] if children.size() > 0 else -1

	for i in range(bones.size()):
		var bone_idx = bones[i]
		var factor = float(i + 1) / bones.size()
		var bone_rot = Vector3(pitch * factor, yaw * factor, 0)
		var bone_quat = Quaternion(bone_rot)
		skeleton.set_bone_pose_rotation(bone_idx, bone_quat)

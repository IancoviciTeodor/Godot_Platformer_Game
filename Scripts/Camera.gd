extends Node3D

var camroot_h = 0
var camroot_v = 0
var cam_v_min = -55
var cam_v_max = 75
var h_sensitivity = 0.1
var v_sensitivity = 0.1
var h_acceleration = 10
var v_acceleration = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#$h/v/Camera.add_exception(get_parent())

func _input(event):
	if event is InputEventMouseMotion:
		camroot_h += -event.relative.x * h_sensitivity
		camroot_v += event.relative.y * v_sensitivity
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camroot_v = clamp(camroot_v, cam_v_min, cam_v_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, float(camroot_h), delta * h_acceleration)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, float(camroot_v), delta * v_acceleration)

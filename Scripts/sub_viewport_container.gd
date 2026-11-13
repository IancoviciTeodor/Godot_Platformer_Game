extends SubViewportContainer

func _ready():
	set_process_unhandled_input(true)

func _input(event):
	# Trimite evenimentul doar dacă este în interiorul SubViewportContainer
	for child in get_children():
		if event is InputEventMouse:
			var mouse_event = event.duplicate()
			mouse_event.position = get_global_transform_with_canvas().affine_inverse() * event.position
			child.get_viewport().push_input(mouse_event)
		else:
			child.get_viewport().push_input(event)

var mouse_pos := Vector2()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_pos = get_canvas_transform().affine_inverse() * event.position

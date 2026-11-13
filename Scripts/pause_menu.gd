extends Control

var buttons = []
var selected_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".hide()
	set_process_mode(PROCESS_MODE_ALWAYS)
	
	$MarginContainer/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	$MarginContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)

	for child in $MarginContainer/VBoxContainer.get_children():
		if child is Button:
			child.focus_mode = Control.FOCUS_ALL
			buttons.append(child)
			
	for button in buttons:
		button.set_focus_mode(Control.FOCUS_ALL)


func _input(event):
	if event is InputEventKey:  # Permite doar tastatură/controller
		if event.is_action_pressed("ui_down"):
			selected_index = min(selected_index + 1, buttons.size() - 1)
		elif event.is_action_pressed("ui_up"):
			selected_index = max(selected_index - 1, 0)
		
		buttons[selected_index].grab_focus()  # Mută selecția
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("p1_quit") or Input.is_action_just_pressed("p2_quit"):
		pause_or_unpause()

func pause_or_unpause():
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$".".hide()
		get_tree().paused = false
	else:
		$".".show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		buttons[selected_index].grab_focus()



func _on_resume_button_pressed() -> void:
	pause_or_unpause()


func _on_main_menu_button_pressed() -> void:
	SoundManager.stop_level_music()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/" + Global.current_level_name + ".tscn")

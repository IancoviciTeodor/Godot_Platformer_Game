extends Control

@onready var next_level_btn = $CanvasLayer/MarginContainer/VBoxContainer/NextLevelButton
@onready var main_menu_btn = $CanvasLayer/MarginContainer/VBoxContainer/MainMenuButton
@onready var message_label = $CanvasLayer/MarginContainer/VBoxContainer/Label

var buttons = []
var selected_index = 0

func _ready():
	for child in $CanvasLayer/MarginContainer/VBoxContainer.get_children():
		if child is Button:  # Adaugă doar butoanele, ignorând Label
			child.focus_mode = Control.FOCUS_ALL
		buttons.append(child)
		
	for button in buttons:
		button.set_focus_mode(Control.FOCUS_ALL)
		
	buttons[selected_index].grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Face cursorul vizibil
	buttons[selected_index].grab_focus()  # Selectează primul buton automat
	
	message_label.text = "Congratulations! You completed Level " + str(Global.current_level - 1)
	
	if Global.current_level > Global.MAX_LEVEL:
		next_level_btn.visible = false  # Ascunde butonul dacă ești la ultimul nivel
	else:
		next_level_btn.visible = true
		next_level_btn.pressed.connect(_on_next_level_button_pressed)

	main_menu_btn.pressed.connect(_on_main_menu_button_pressed)

func _input(event):
	if event is InputEventKey:  # Permite doar tastatură/controller
		if event.is_action_pressed("ui_down"):
			selected_index = min(selected_index + 1, buttons.size() - 1)
		elif event.is_action_pressed("ui_up"):
			selected_index = max(selected_index - 1, 0)
		
		buttons[selected_index].grab_focus()  # Mută selecția
	
		if event.is_action_pressed("ui_accept"):
			buttons[selected_index].emit_signal("pressed")  # Apasă butonul selectat


func _on_next_level_button_pressed() -> void:
	SoundManager.stop_level_music()
	get_tree().change_scene_to_file("res://Scenes/level_" + str(Global.current_level) + ".tscn")


func _on_main_menu_button_pressed() -> void:
	SoundManager.stop_level_music()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

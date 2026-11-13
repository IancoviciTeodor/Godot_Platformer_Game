extends Control

@onready var label = $CanvasLayer/MarginContainer/VBoxContainer/Label

var buttons = []
var selected_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.add_theme_constant_override("margin_bottom", 50)
	label.add_theme_constant_override("margin_bottom", 50)
	
	for child in $CanvasLayer/MarginContainer/VBoxContainer.get_children():
		if child is Button:  # Adaugă doar butoanele, ignorând Label
			child.focus_mode = Control.FOCUS_ALL
		buttons.append(child)
		
	for button in buttons:
		button.set_focus_mode(Control.FOCUS_ALL)
		
	buttons[selected_index].grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Face cursorul vizibil
	buttons[selected_index].grab_focus()  # Selectează primul buton automat


func _input(event):
	if event is InputEventKey:  # Permite doar tastatură/controller
		if event.is_action_pressed("ui_down"):
			selected_index = min(selected_index + 1, buttons.size() - 1)
		elif event.is_action_pressed("ui_up"):
			selected_index = max(selected_index - 1, 0)
		
		buttons[selected_index].grab_focus()  # Mută selecția
	
		if event.is_action_pressed("ui_accept"):
			buttons[selected_index].emit_signal("pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

extends GridContainer

@onready var viewport_container_1: SubViewportContainer = $SubViewportContainer1
@onready var viewport_container_2: SubViewportContainer = $SubViewportContainer2
@onready var sub_viewport_2: SubViewport = viewport_container_2.get_child(0)
@onready var player_2 = $"SubViewportContainer2/SubViewport/Fire-Bot"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var has_player_2 = sub_viewport_2.get_child_count() > 0
	if has_player_2:
		player_2.visible = false # Ascunde Player_2


func _process(delta):
	# Verifică dacă SubViewport-ul 2 conține un caracter
	var has_player_2 = sub_viewport_2.get_child_count() > 0
	var controller_connected = Input.get_connected_joypads().size() > 0
	
	if has_player_2 and controller_connected:
		columns = 2
		viewport_container_2.visible = true
		player_2.visible = true  # Player_2 devine vizibil
	else:
		columns = 1
		viewport_container_2.visible = false

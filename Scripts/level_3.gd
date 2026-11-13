extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_level_music()
	Global.coins = 0
	Global.NUM_COINS_TO_WIN = 20
	Global.current_level_name = "level_3"
	Global.current_level = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_fall_zone_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.position = Vector3(0, 1, 0)
		body.velocity = Vector3.ZERO

func _on_resume_button_pressed() -> void:
	pass # Replace with function body.

extends CanvasLayer

@onready var tex := $TextureRect

func _ready() -> void:
	# Asigură-te că este centrat
	tex.anchor_left = 0.5
	tex.anchor_top = 0.5
	tex.anchor_right = 0.5
	tex.anchor_bottom = 0.5

	tex.offset_left = -tex.size.x / 2
	tex.offset_top = -tex.size.y / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Area3D

var speed := 30.0
var direction := Vector3.ZERO

func _ready():
	scale = Vector3(0.1, 0.1, 0.1) # începe mic
	var t = create_tween() # tween de creștere
	t.tween_property(self, "scale", Vector3(1, 1, 1), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Functia de despawn
	call_deferred("_start_despawn")


func _physics_process(delta):
	# Raycast înainte de mișcare
	$RayCast3D.target_position = direction * speed * delta
	$RayCast3D.force_raycast_update()

	if $RayCast3D.is_colliding():
		var hit = $RayCast3D.get_collider()

		if hit.is_in_group("enemy"):
			hit.take_damage(1)
		queue_free()
		return

	# Dacă nu lovește nimic se mișcă normal
	global_translate(direction * speed * delta)

	# Orientare spre direcție
	look_at(global_transform.origin + direction, Vector3.UP)

	rotate_y(deg_to_rad(90)) # Rotate the model


func _on_body_entered(body):
	# Dacă lovește un inamic
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
		return

	# Dacă lovește terenul (layer 2)
	if body.get_collision_layer_value(2):
		queue_free()

func _start_despawn():
	await get_tree().create_timer(4.0).timeout
	queue_free()

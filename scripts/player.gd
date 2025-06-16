extends Area2D

signal hit
signal obstacle_passed
signal respawned  # Nueva señal para notificar el respawn

@export var fall_gravity := 10
@export var magnitude = 50
var velocity := Vector2.ZERO
var screen_size 
var timer := 0.0
var is_active := false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	
func _process(delta: float) -> void:
	if !is_active: return
	
	timer += delta
	if timer >= 1.0:
		timer = 0.0
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
		
	if Input.is_action_pressed("floating"):
		$"../AudioTap".play()
		var mouse_pos = get_global_mouse_position()
		var direction = (position - mouse_pos).normalized()
		var impulse = direction * magnitude
		
		velocity.y = 0
		velocity.x = 0
		velocity += impulse
		
	# Aplicar gravedad
	velocity.y += fall_gravity * delta
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(body: Node2D) -> void:
	if !is_active: return
	die()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("obstacle") and is_active:
		obstacle_passed.emit()

func start(pos: Vector2):
	reset(pos)

# Nueva función de reset completo
func reset(pos: Vector2):
	$AnimatedSprite2D.play("floating")
	position = pos
	velocity = Vector2.ZERO
	timer = 0.0
	is_active = true
	show()
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.show()
	emit_signal("respawned")

func stop_movement():
	velocity = Vector2.ZERO

func die():
	if !is_active: return
	is_active = false
	$"../AudioGloboRebentado".play()
	$AnimatedSprite2D.play("Die")

	await get_tree().create_timer(0.6).timeout
	
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

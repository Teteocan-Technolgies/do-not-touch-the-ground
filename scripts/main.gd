extends Node

@export var meteorito_scene: PackedScene
@export var bird_scene: PackedScene
@export var Tcollaboration_scene: PackedScene

var score = 0
var is_first_launch := true  # NUEVO: Variable para controlar primera ejecución
var tcollaboration_instance = null  # NUEVO: Referencia a la instancia
@onready var hud = $HUD as CanvasLayer  # Referencia al CanvasLayer que contiene la UI
@onready var background_music = $BackgroundMusic

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	play_background_music()
	Engine.time_scale = 0.0
	# Carga y reproduce la música automáticamente
	# Conexión segura de señales de timers
	if not $ScoreTimer.timeout.is_connected(_on_score_timer_timeout):
		$ScoreTimer.timeout.connect(_on_score_timer_timeout)
	
	if not $MeteoritoTimer.timeout.is_connected(_on_meteorito_timer_timeout):
		$MeteoritoTimer.timeout.connect(_on_meteorito_timer_timeout)
	
	if not $StartTimer.timeout.is_connected(_on_start_timer_timeout):
		$StartTimer.timeout.connect(_on_start_timer_timeout)
	
	# Nueva conexión de señal retry_requested
	if hud.has_signal("retry_requested") and not hud.retry_requested.is_connected(_on_retry_requested):
		hud.retry_requested.connect(_on_retry_requested)
	else:
		printerr("No se pudo conectar retry_requested")
	#MODIFICADO: Mostrar Tcollaboration solo en primer lanzamiento
	if is_first_launch:
		show_tcollaboration_scene()
	else:
		new_game()

# NUEVO: Función para mostrar la escena Tcollaboration
func show_tcollaboration_scene():
	if Tcollaboration_scene == null:
		printerr("Error: Tcollaboration_scene no está asignada")
		new_game()
		return
	
	# Instanciar la escena de colaboración
	tcollaboration_instance = Tcollaboration_scene.instantiate()
	add_child(tcollaboration_instance)
	
	# Conectar señal para cuando termine la escena de colaboración
	if tcollaboration_instance.has_signal("collaboration_finished"):
		tcollaboration_instance.collaboration_finished.connect(_on_collaboration_finished)
	elif tcollaboration_instance.has_signal("finished"):
		tcollaboration_instance.finished.connect(_on_collaboration_finished)
	else:
		# Si no tiene señal, usar un timer como fallback (5 segundos)
		var timer = Timer.new()
		timer.wait_time = 0.3
		timer.one_shot = true
		timer.timeout.connect(_on_collaboration_finished)
		add_child(timer)
		timer.start()

# NUEVO: Función que se llama cuando termina la escena de colaboración
func _on_collaboration_finished():
	is_first_launch = false
	
	# Eliminar la escena de colaboración
	if tcollaboration_instance != null and is_instance_valid(tcollaboration_instance):
		tcollaboration_instance.queue_free()
		tcollaboration_instance = null
	
	# Iniciar el juego principal
	new_game()

func cleanup_meteorites_on_pause(paused: bool):
	if paused:
		# Elimina todos los meteoritos al pausar
		get_tree().call_group("meteorito", "queue_free")
		
func start_game():
	# Reanuda el juego completamente
	Engine.time_scale = 1.0
	$StartTimer.start()
	new_game()
	
func play_background_music():
	if background_music:
		background_music.play()
	
func game_over():
	# CORRECCIÓN: Pausar el juego y limpiar todos los enemigos
	Engine.time_scale = 0.0
	
	# Detener todos los timers
	$ScoreTimer.stop()
	$MeteoritoTimer.stop()
	$StartTimer.stop()
	
	# Limpiar TODOS los enemigos (meteoritos y pájaros) INMEDIATAMENTE
	cleanup_all_enemies()
	
	# Forzar eliminación inmediata
	get_tree().call_deferred("process_frame")
	
	# Detener el movimiento del player
	if $Player.has_method("stop_movement"):
		$Player.stop_movement()
	
	# Mostrar game over en HUD
	if hud.has_method("game_over"):
		hud.game_over()

func cleanup_all_enemies():
	# Método más directo: eliminar por nombre de escena/clase
	for child in get_children():
		# Verificar si el nodo es un meteorito o pájaro
		if child.scene_file_path != null:
			var scene_name = child.scene_file_path.get_file().to_lower()
			if "meteorito" in scene_name or "meteor" in scene_name or "bird" in scene_name or "pajaro" in scene_name:
				child.queue_free()
		# Alternativa: verificar por el nombre de la clase/script
		elif child.get_script() != null:
			var script_path = child.get_script().get_path().get_file().to_lower()
			if "meteorito" in script_path or "meteor" in script_path or "bird" in script_path or "pajaro" in script_path:
				child.queue_free()
		# Última alternativa: verificar por el nombre del nodo
		elif child.name.to_lower().contains("meteorito") or child.name.to_lower().contains("meteor") or child.name.to_lower().contains("bird") or child.name.to_lower().contains("pajaro"):
			child.queue_free()
	
	# También limpiar usando los grupos por si acaso
	get_tree().call_group("meteoritos", "queue_free")
	get_tree().call_group("birds", "queue_free")
	
func new_game():
	score = 0
	
	# Detener todos los timers
	$ScoreTimer.stop()
	$MeteoritoTimer.stop()
	$StartTimer.stop()
	
	# Limpiar todos los enemigos existentes
	cleanup_all_enemies()
	
	# Esperar un frame para que se eliminen las instancias
	await get_tree().process_frame
	
	# Reiniciar jugador
	$Player.reset($StartPosition.position)
	
	# Actualizar UI
	if hud.has_method("update_score"):
		hud.update_score(score)
	
	# Reiniciar el juego
	$StartTimer.start()

func _on_meteorito_timer_timeout() -> void:
	# Create a new instance of the Meteorito scene.
	var meteorito = meteorito_scene.instantiate()

	# Choose a random location on Path2D.
	var meteorito_spawn_location = $MeteoritoPath/MeteoritoSpawnLocation
	meteorito_spawn_location.progress_ratio = randf()

	# Set the meteorito's position to the random location.
	meteorito.position = meteorito_spawn_location.position

	# Set the meteorito's direction perpendicular to the path direction.
	var direction = meteorito_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	meteorito.rotation = direction

	# Choose the velocity for the meteorito.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	meteorito.linear_velocity = velocity.rotated(direction)
	
	meteorito.get_node("AnimatedSprite2D").flip_h = true
	
	if meteorito.linear_velocity.x > 0:
		meteorito.get_node("AnimatedSprite2D").flip_v = true
	else:
		meteorito.get_node("AnimatedSprite2D").flip_v = false

	# Spawn the meteorito by adding it to the Main scene.
	add_child(meteorito)
	
	#Bird from Left
	var bird_left = bird_scene.instantiate()
	
	# Choose a random location on Path2D.
	var bird_left_spawn_location = $BirdLeftPath/BirdLeftLocation
	bird_left_spawn_location.progress_ratio = randf()
	
	# Set the bird's left position to the random location.
	bird_left.position = bird_left_spawn_location.position

	# Set the bird's direction perpendicular to the path direction.
	var bird_direction = bird_left_spawn_location.rotation + PI / 2
	
	# Choose the velocity for the bird.
	var bird_left_velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	bird_left.linear_velocity = bird_left_velocity.rotated(bird_direction)
	

	# Spawn the mob by adding it to the Main scene.
	add_child(bird_left)
	
	#Bird from Right
	var bird_right = bird_scene.instantiate()
	
	# Choose a random location on Path2D.
	var bird_right_spawn_location = $BirdRightPath/BirdRightLocation
	bird_right_spawn_location.progress_ratio = randf()
	
	# Set the bird's left position to the random location.
	bird_right.position = bird_right_spawn_location.position

	# Set the bird's direction perpendicular to the path direction.
	var bird_right_direction = bird_right_spawn_location.rotation + PI / 2
	
	# Flip the sprite horizontalmente para que apunte a la izquierda
	bird_right.get_node("AnimatedSprite2D").flip_h = true
	
	# Choose the velocity for the bird.
	var bird_right_velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	bird_right.linear_velocity = bird_right_velocity.rotated(bird_right_direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(bird_right)

func _on_score_timer_timeout() -> void:
	score += 1
	if is_instance_valid(hud) and hud.has_method("update_score"):
		hud.update_score(score)
	else:
		printerr("Error: No se pudo actualizar el puntaje en HUD")

func _on_start_timer_timeout() -> void:
	$MeteoritoTimer.start()
	$ScoreTimer.start()
	
func _on_retry_requested():
	new_game()  # Esto reinicia tu juego
	
	# Opcional: Limpiar meteoritos existentes
	get_tree().call_group("meteoritos", "queue_free")

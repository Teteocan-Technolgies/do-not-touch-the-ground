extends CanvasLayer

var score = 0
var time_passed = 0
var game_active = false
signal retry_requested  # Corrige el nombre para que coincida

#Diccionario de datos
var game_data = {
	"max_score": 0,
	"max_time_passed": 0
}

func _save_game():
	#Actualizar los datos maximos
	if score > game_data["max_score"]:
		game_data["max_score"] = score
	if time_passed > game_data["max_time_passed"]:
		game_data["max_time_passed"] = time_passed
	
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_data))
		#print("Datos guardados")
	#else:
		#print("Error al guardar: ", FileAccess.get_open_error())

func _load_game():
	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			game_data = json.data
			#print("max_score: ", game_data["max_score"])
			#print("max_time_passed: ", game_data["max_time_passed"])
			#print("Datos cargados")
		else:
			_reset_to_default()
			#print("Error al parsear JSON, usando valores por defecto")
			
	else:
		_reset_to_default()
		#print("No se encontro el archivo")

func _reset_to_default():
	game_data["max_score"] = score
	game_data["max_time_passed"] = time_passed
	_save_game()

func _ready():
	_load_game()
	
	$StartScreen.show()
	$GameUI.hide()
	$GameOverScreen.hide()
	$StartScreen/StartButton.pressed.connect(_on_start_button_pressed)
	$GameOverScreen/Retry.pressed.connect(_on_retry_pressed)

func _on_start_button_pressed():
	var main = get_parent()
	if main.has_method("start_game"):
		main.start_game()
	
	# Oculta elementos UI
	$StartScreen.hide()
	$GameUI.show()
	score = 0
	time_passed = 0
	game_active = true
	update_score(0)
	update_time()

func update_score(value: int):  # Ahora acepta parámetro
	score = value
	if score > game_data["max_score"]: game_data["max_score"] = score
	$GameUI/Puntuacion.text = "Puntos: %d" % score

func update_time():
	if time_passed > game_data["max_time_passed"]: game_data["max_time_passed"] = time_passed
	$GameUI/Tiempo.text = "Tiempo: %ds" % int(time_passed)

func game_over():
	game_active = false
	$GameUI.hide()
	$GameOverScreen.show()
	$GameOverScreen/FinalScore.text = "Puntaje final: %d" % score
	$GameOverScreen/FinalTime.text = "Tiempo final: %d" % time_passed
	$GameOverScreen/MaxPuntaje.text = "Maximo puntaje: %d" % game_data["max_score"]
	$GameOverScreen/MaxtimePassed.text = "Maximo tiempo: %d" % game_data["max_time_passed"]
	
	_save_game()
	

func _process(delta):
	if game_active:
		time_passed += delta
		if int(time_passed) % 1 == 0:
			update_time()


func _on_retry_pressed():
	# Emitir señal para que main sepa que debe reiniciar
	emit_signal("retry_requested")
	# Ocultar game over y mostrar pantalla inicial
	$GameOverScreen.hide()
	$StartScreen.show()

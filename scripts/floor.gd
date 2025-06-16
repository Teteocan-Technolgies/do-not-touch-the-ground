extends StaticBody2D

func _on_Floor_body_entered(body):
	if body.name == "Player":
		body.queue_free()
		get_tree().change_scene_to_file("res://GameOver.tscn")

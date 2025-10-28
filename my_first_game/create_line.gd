extends Node2D	
var player1=preload("res://first_player.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("load"):
		var player_instance=player1.instantiate()
		player_instance.position.x=position.x+200
		player_instance.position.y=position.y+200
		add_child(player_instance)
		get_tree().change_scene_to_file("res://scenes/Gam")

extends Node2D


var level_template = preload("res://Scenes/level_template.tscn").instantiate()
var current_level_number: int
var current_level_node
# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_number = 0
	load_level()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_level():
	match current_level_number:
		0:
			current_level_node = level_template
		_:
			print("made it to some other level")
			return
	add_child(current_level_node)
	current_level_node.position.x = 0
	current_level_node.position.y = 0

func player_died():
	#change the level
	print("player has died!")
	level_template.queue_free()

func player_won():
	#change the level
	print("player reached checkpoint!")
	current_level_node.queue_free()
	current_level_number += 1
	load_level()
	

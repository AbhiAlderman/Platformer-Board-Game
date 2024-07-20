extends Node2D

signal on_player_death
@onready var test = $Tilemaps/test
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(test)
	timer.start()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_died():
	get_parent().player_died()

func player_won():
	get_parent().player_won()


func _on_timer_timeout():
	add_child(test)

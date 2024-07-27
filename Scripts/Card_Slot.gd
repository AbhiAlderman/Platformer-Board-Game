extends Node2D

@onready var button = $Button
@onready var sprite = $AnimatedSprite2D
var has_focus: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func disable_slot():
	button.disabled = true
	sprite.play("inactive")

func _on_button_focus_entered():
	pass # Replace with function body.


func _on_button_focus_exited():
	pass # Replace with function body.


func _on_button_pressed():
	pass # Replace with function body.
